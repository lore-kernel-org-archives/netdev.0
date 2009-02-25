From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: move IPv6 support into a separate kernel
 module
Date: Wed, 25 Feb 2009 14:14:30 -0800 (PST)
Message-ID: <20090225.141430.166906161.davem@davemloft.net>
References: <49A5ADB3.2010709@hp.com>
	<28797.1235599858@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, arvidjaar@mail.ru, vladislav.yasevich@hp.com,
	chuck.lever@oracle.com, tytso@mit.edu, Valdis.Kletnieks@vt.edu,
	rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34697
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759718AbZBYWOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 17:14:46 -0500
In-Reply-To: <28797.1235599858@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Wed, 25 Feb 2009 14:10:58 -0800

> 	I've been fooling with the disable_ipv6 sysctl, and one issue is
> that, at least on the distro I'm testing on (SLES), it's not picked up
> from /etc/sysctl.conf at boot time (presumably because ipv6 isn't loaded
> yet, although I haven't really checked).

Correct, that's the problem.

We could create a blocker bitmap.  Two sysctls, "block_af" and
"unblock_af".  You write the AF_foo value for the protocol there and
it sets or clears the assosciated bit in the internal blocker bitmap.

Things like sys_socket() et al. key off of this.
