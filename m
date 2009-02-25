From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v2] bonding: move IPv6 support into a separate kernel module
Date: Wed, 25 Feb 2009 14:10:58 -0800
Message-ID: <28797.1235599858@death.nxdomain.ibm.com>
References: <49A5ADB3.2010709@hp.com>
Cc: David Miller <davem@davemloft.net>,
	Andrey Borzenkov <arvidjaar@mail.ru>,
	Vladislav Yasevich <vladislav.yasevich@hp.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Theodore Tso <tytso@mit.edu>, Valdis.Kletnieks@vt.edu,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bonding-devel@lists.sourceforge.net,
	=?ISO-8859-1?Q?=22J=2EA=2E_Magall?= =?ISO-8859-1?Q?=F3n=22?=
	<jamagallon@ono.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:42026 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753200AbZBYWLG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 17:11:06 -0500
In-reply-to: <49A5ADB3.2010709@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> wrote:
[...]
>This patch moves the IPv6 bonding code into a separate kernel module
>called bonding_ipv6 if either bonding or IPv6 are built as modules.
>If both are built into the kernel then this is as well.  Bonding_ipv6.ko
>registers an "send_unsol_na" function pointer for the unsolicited
>advertisement function to be called on a failover - the default action
>is to do nothing.  The notifier callbacks are now registered in this
>module and not in the base bonding module.
>
>Also, have the IPv6 address notifier request that the bonding_ipv6
>module be loaded when an IFF_MASTER device is first brought-up.
>This avoids users from having to do this explicitly with modprobe.

	I'm not entirely sure what the right solution for all of this
is, but it doesn't seem to me that cranking on bonding and adding a
special case to ipv6 is the best way to go.

	This patch won't resolve the reported similar (but presumably
lower profile) issues with SCTP or qeth, and it seems unlikely that this
is the last time some driver will gain a run time dependence on ipv6
after being compiled with CONFIG_IPV6.

Theodore Tso <tytso@mit.edu> wrote (in a different thread):
>I think I can pretty much guarantee that distro users will be
>clamoring for a quick and easy way to block ipv6, and it's in our
>interest to document the recomended way to block it that doesn't cause
>weird problems with bonding, etc.

	I agree with this.  

	I've been fooling with the disable_ipv6 sysctl, and one issue is
that, at least on the distro I'm testing on (SLES), it's not picked up
from /etc/sysctl.conf at boot time (presumably because ipv6 isn't loaded
yet, although I haven't really checked).


	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
