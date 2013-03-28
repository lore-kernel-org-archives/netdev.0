From: David Shwatrz <dshwatrz@gmail.com>
Subject: Re: Deleting a network namespace
Date: Thu, 28 Mar 2013 16:12:32 +0200
Message-ID: <CAJJAcof9Tgnoudq+Wk+68UCsjGHX9cu=OnpKQdpWR5amijFAtw@mail.gmail.com>
References: <CAJJAcodGG6nmRNcF_rC+AUUpCp1MWjU3faGLfRTm9FNc6LT_Yw@mail.gmail.com>
	<87y5d7lr73.fsf@xmission.com>
	<CAJJAcof98k+GDt88MORMz6sS-JFODeuyqYSwP6dk-ZYqFMGTWg@mail.gmail.com>
	<87hajvhbe3.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f173.google.com ([209.85.128.173]:45673 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755756Ab3C1OMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 10:12:33 -0400
Received: by mail-ve0-f173.google.com with SMTP id cy12so3334113veb.18
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 07:12:32 -0700 (PDT)
In-Reply-To: <87hajvhbe3.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
Thanks a lot for the detailed explanation!

>As for the rest having software based network devices vanish >is by
>design and I can't think of a single reason why it would make >sense to
>do anything differently.
Agreed.

Best,
DS

On Thu, Mar 28, 2013 at 4:00 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> David Shwatrz <dshwatrz@gmail.com> writes:
>
>> Hello,
>> I checked and indeed physical hardware are moved to init_net.
>> I wonder how it is done, as in netns_delete() there is only
>> umount2() and unlink() syscalls (might these syscalls trigger this
>> movement to init_net)?
>
> The mount holds a refcount to the network namespace, the unmount drops
> that refcount.
>
>> I really could not figure how this is
>> implemented and where in code do we differentiate between physical and
>> non physical devices.
>
> When the refcount drops to zero put_net calls __put_net in
> net/core/net_namespace.c which wiggles around and arranges
> for cleanup_net to be called.
>
> As for what happens to the network devices look at default_device_exit
> and default_device_exit_batch in net/core/dev.c
>
> As for the rest having software based network devices vanish is by
> design and I can't think of a single reason why it would make sense to
> do anything differently.  Depending on your configuration the initial
> network namespace really isn't where you would want network devices to
> be moved.   Think about what happens when you run your use can in a lxc
> based container for example.
>
> Eric
