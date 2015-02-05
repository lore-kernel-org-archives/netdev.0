From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: FW: gre interfaces copied to new namespace
Date: Thu, 05 Feb 2015 17:58:55 -0600
Message-ID: <87pp9n3o74.fsf@x220.int.ebiederm.org>
References: <EDD8E64855FBDA45ACDFE02112E795B7109CB5DC7A@HQ1-EXCH03.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: Steve Biggs <sbiggs@Brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53731 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753163AbbBFACI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 19:02:08 -0500
In-Reply-To: <EDD8E64855FBDA45ACDFE02112E795B7109CB5DC7A@HQ1-EXCH03.corp.brocade.com>
	(Steve Biggs's message of "Thu, 5 Feb 2015 15:44:01 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Biggs <sbiggs@Brocade.com> writes:

> Sorry, forgot to include you as CC. Been a long time since I've posted
> to an open source list, so I'm probably going to make mistakes that
> hopefully won't get me kicked off or start a flame war, as I already
> have as you can see below.  :-(

Weird.  I haven't seen a copy of this through the netdev mailling list.

> -----Original Message-----
> From: Steve Biggs 
> Sent: Thursday, February 05, 2015 3:38 PM
> To: 'netdev@vger.kernel.org'
> Subject: gre interfaces copied to new namespace
>
> (My first post to this list. I forgot to change my settings and I sent
> the previous version of this post using HTML mail. Terribly sorry if
> this caused anybody any problems; won't happen again... it may be that
> it never got to the list at all?)
>
> I am going under the assumption that a newly created network namespace
> should have the loopback (lo) device as its only contents, with it
> being an error to have any other already existing interfaces in the
> default namespace also copied in. If this assumption is wrong, please
> advise and then if so, sorry for the noise.

There may be one or two other devices (tunnels) in a newly created
network namespace whose purpose is to allow the old ioctl tunnel
creation APIs to work.

I think it is silly that we provide the backwards compatibility with the
brand-new gretap interfaces but otherwise I don't see anything to
complain about with the commands you have given.

I thought you said something in here triggered a BUG_ON.

> I was able to reproduce this on a vanilla Debian Wheezy installation
> with the following sequence of commands. Debian Wheezy is running an
> older kernel version, so this is a long-standing issue. I am also able
> to reproduce this on a 3.14.y based kernel.

Before reading the commands below I hadn't realized you could
type "ip a" instead of "ip addr list"

> # ip netns list
> # ip a
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default 
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>     inet 127.0.0.1/8 scope host lo
>        valid_lft forever preferred_lft forever
>     inet6 ::1/128 scope host 
>        valid_lft forever preferred_lft forever
> # modprobe ip_gre
> # ip a
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default 
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>     inet 127.0.0.1/8 scope host lo
>        valid_lft forever preferred_lft forever
>     inet6 ::1/128 scope host 
>        valid_lft forever preferred_lft forever
> 12: gre0@NONE: <NOARP> mtu 1476 qdisc noop state DOWN group default 
>     link/gre 0.0.0.0 brd 0.0.0.0
> 13: gretap0@NONE: <BROADCAST,MULTICAST> mtu 1462 qdisc noop state DOWN group default qlen 1000
>     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
> # ip netns add foo
> # ip netns list foo
> # ip netns exec foo ip a
> 1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default 
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> 2: gre0@NONE: <NOARP> mtu 1476 qdisc noop state DOWN group default 
>     link/gre 0.0.0.0 brd 0.0.0.0
> 3: gretap0@NONE: <BROADCAST,MULTICAST> mtu 1462 qdisc noop state DOWN group default qlen 1000
>     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
> # rmmod ip_gre
> # ip netns exec foo ip a
> 1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default 
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> # ip netns del foo
> # ip netns list
> #


Eric
