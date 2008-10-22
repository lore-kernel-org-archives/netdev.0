From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/4][RFC] netns: sysfs: add a netns suffix to net device sysfs entries
Date: Wed, 22 Oct 2008 14:01:59 -0700
Message-ID: <m18wsgmji0.fsf@frodo.ebiederm.org>
References: <20081022152144.351965414@theryb.frec.bull.fr>
	<m1d4hso0ym.fsf@frodo.ebiederm.org> <20081022203045.GA4633@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	netdev <netdev@vger.kernel.org>,
	Dave Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.linux-foundation.org>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:46659 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757429AbYJVVEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 17:04:33 -0400
In-Reply-To: <20081022203045.GA4633@us.ibm.com> (Serge E. Hallyn's message of
	"Wed, 22 Oct 2008 15:30:45 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Quoting Eric W. Biederman (ebiederm@xmission.com):
>> Benjamin Thery <benjamin.thery@bull.net> writes:
>> 
>> > Support for network namespaces in mainline is pretty complete for
>> > some time now, but there is still this issue with sysfs that prevents 
>> > more people to use it easily.
>> 
>> Ben your patchset is completely inappropriate.
>> 
>> Temporarily adding elements to the ABI that we intend to remove
>> is not a proper solution to this problem.
>> 
>> That user space visible ida you add is a namespace identifier that breaks
>> nested containers and migration.  It is very very very wrong.
>
> I disagree (not surprising :) completely.  The well-known userspace
> tools (ifconfig, ip, etc) will not see the lo@1, they'll see lo.
> Userspace in a container can either umount /sys completely, or do

The well-known user space tools don't use /sys at all.  Modern
network tools use rtnetlink (ip) old network tools use /proc/net.

Very few things actually use /sys and for those things lo@1 or
eth0@1 are completely useless except for implementing a FUSE
mock up of sysfs.  But you don't need anything in sysfs to do
that as all of the interesting information is available through
/proc/net or rtnetlink.

>
> 	mount -t tmpfs none /sys/class/net
> 	mount --bind /sys/devices/virtual/net/lo@1 /sys/class/net/lo
>
> if they really want to, in which case only their view
> of /sys/devices/virtual/net would be different.
>
> Eric, would you hate this less if it was under some
>
> 	CONFIG_SYSFS_NETNS_HACK
>
> config variable?

No.  ABI decisions are almost certainly irreversible.

If we need an immediate hack please see the patch I sent
in follow up.  We can achieve everything Ben is doing by simply
keeping virtual devices out of the kobject tree.  Keeping them
from showing up in sysfs.

Eric
