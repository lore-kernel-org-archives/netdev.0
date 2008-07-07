From: Bill Nottingham <notting@redhat.com>
Subject: Re: [RFC PATCH 0/2] Allow full bridge configuration via sysfs
Date: Mon, 7 Jul 2008 17:34:20 -0400
Message-ID: <20080707213420.GA20089@nostromo.devel.redhat.com>
References: <cover.1215460681.git.notting@redhat.com> <4872819E.3040604@trash.net> <20080707205342.GA19710@nostromo.devel.redhat.com> <4872838B.1060603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35801 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755344AbYGGVfX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 17:35:23 -0400
Content-Disposition: inline
In-Reply-To: <4872838B.1060603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy (kaber@trash.net) said: 
>> Also, moving bonding configuration to netlink seems
>> like a step backwards.
>
> Please read up on what the standard interface for network
> configuration is

OK, let's see.

In the code: Hm, no TODO or FIXME.

In the included documentation:

Documentation/networking/bonding.txt:
  Module options, modprobe.conf, or 'distro-specific
  configuration file', ifenslave, or sysfs.

Documentation/networking/ip-sysctl.txt:
  sysctl, obviously.

Documentation/networking/generic_netlink.txt
  Hey, here's netlink! Doucmentation points only to a wiki. Referred
  to by zero other included in-kernel documentation.

Well, that's helpful.

Let's try the OSDL web!

http://www.linuxfoundation.org/en/Net:Bridge
  brctl (which uses ioctl and sysfs). And /etc/net.
  
http://www.linuxfoundation.org/en/Net:Bonding
  Module parameters only, including the lovely 'load driver multiple times'
  method. Doesn't even mention sysfs.

http://www.linuxfoundation.org/en/Net:VLAN
  vconfig
  
I could look at wireless network configuration, but I doubt that's going to
help your argument.

> I'm tired of reiterating this once a week.

Well, if the documentation that described this as the standard existed,
or wasn't such crap, perhaps you wouldn't have to.

That being said, how is moving from adding a bonding slave from:
  echo "+eth0" >  /sys/class/net/bond0/bonding/slaves to:
to:
  http://www.linuxfoundation.org/en/Net:Generic_Netlink_HOWTO

a worthwhile improvement for the admin? Let's see, a kernel-userspace
protocol with magic message formats. Hey, we reinvented ioctl!

Why, if netlink is the standard (and it's been around for a long
damn time), was sysfs configuration for bonding added in 2005? Why
was bridge configuration added in 2005, and *extended* in 2006 and
2007? Why were the user-space tools such as brctl ported from ioctl
to sysfs?

Bill
