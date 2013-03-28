From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Deleting a network namespace
Date: Thu, 28 Mar 2013 04:05:52 -0700
Message-ID: <87y5d7lr73.fsf@xmission.com>
References: <CAJJAcodGG6nmRNcF_rC+AUUpCp1MWjU3faGLfRTm9FNc6LT_Yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:41783 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374Ab3C1LGE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 07:06:04 -0400
In-Reply-To: <CAJJAcodGG6nmRNcF_rC+AUUpCp1MWjU3faGLfRTm9FNc6LT_Yw@mail.gmail.com>
	(David Shwatrz's message of "Thu, 28 Mar 2013 12:43:27 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Shwatrz <dshwatrz@gmail.com> writes:

> Hello,
> When assigning a network interface to a network namespace and
> afterwards deleting the namespace, we will not see the network
> interface in any other namespace (including the default namespace) an=
ymore:
>
> ip netns add ns1
> ip link set=C2=A0eth0 netns ns1
> ip netns del ns1
>
> This means that in fact we cannot use this interface again (only afte=
r
> rebooting)
> Am I right on this ?

Interfaces that represent physical hardware are moved to init_net.
Interfaces that are purely software constructs are deleted.

> Is moving an interface back to the default (init) namespace,
> when deleting the namespace which contains it, can be considered?

If you aren't seeing that your interface is either a purely software
construct like the veth or dummy interfaces or something still has a
reference to your network namespace.

Eric
