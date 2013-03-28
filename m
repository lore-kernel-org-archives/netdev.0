From: David Shwatrz <dshwatrz@gmail.com>
Subject: Re: Deleting a network namespace
Date: Thu, 28 Mar 2013 15:41:25 +0200
Message-ID: <CAJJAcof98k+GDt88MORMz6sS-JFODeuyqYSwP6dk-ZYqFMGTWg@mail.gmail.com>
References: <CAJJAcodGG6nmRNcF_rC+AUUpCp1MWjU3faGLfRTm9FNc6LT_Yw@mail.gmail.com>
	<87y5d7lr73.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f178.google.com ([209.85.220.178]:62737 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755711Ab3C1Nl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 09:41:26 -0400
Received: by mail-vc0-f178.google.com with SMTP id hz11so7555745vcb.23
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 06:41:25 -0700 (PDT)
In-Reply-To: <87y5d7lr73.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I checked and indeed physical hardware are moved to init_net.
I wonder how it is done, as in netns_delete() there is only
umount2() and unlink() syscalls (might these syscalls trigger this
movement to init_net)? I really could not figure how this is
implemented and where in code do we differentiate between physical and
non physical devices.

Best,
DS

On Thu, Mar 28, 2013 at 1:05 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> David Shwatrz <dshwatrz@gmail.com> writes:
>
>> Hello,
>> When assigning a network interface to a network namespace and
>> afterwards deleting the namespace, we will not see the network
>> interface in any other namespace (including the default namespace) anymore:
>>
>> ip netns add ns1
>> ip link set eth0 netns ns1
>> ip netns del ns1
>>
>> This means that in fact we cannot use this interface again (only after
>> rebooting)
>> Am I right on this ?
>
> Interfaces that represent physical hardware are moved to init_net.
> Interfaces that are purely software constructs are deleted.
>
>> Is moving an interface back to the default (init) namespace,
>> when deleting the namespace which contains it, can be considered?
>
> If you aren't seeing that your interface is either a purely software
> construct like the veth or dummy interfaces or something still has a
> reference to your network namespace.
>
> Eric
