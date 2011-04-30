From: Kamil Iskra <kamil@iskra.name>
Subject: WoL stopped working after power off with 2.6.38 (e1000e specific?)
Date: Sat, 30 Apr 2011 00:45:19 -0500
Message-ID: <20110430054519.GA9826@scooby.iskra.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from scooby.iskra.name ([67.202.109.208]:56281 "EHLO mail.iskra.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752778Ab1D3GBM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Apr 2011 02:01:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Note: I'm not on these mailing lists, so be sure to Cc: me if you want
more info from me ]

After upgrading from kernel 2.6.37 to 2.6.38, Wake on LAN after shutdown
stopped working for me on both of my Thinkpad laptops.  Both systems use
the e1000e driver.  One (a T61) has an 82566MM NIC, the other (an X201) an
82577LM.  I'm running 64-bit Gentoo Linux with a custom compiled kernel.
The network driver is built into the kernel.

Wake on LAN still works after suspend (S3), but not after a complete
shutdown (with power supply connected).

I figured the updated e1000e driver in 2.6.38 was probably to blame,
however, after I copied the whole drivers/net/e1000e directory from the
2.6.37 over to the 2.6.38 tree and recompiled, the problem persisted, so I
don't know anymore.

I modified the system shutdown sequence to invoke ifconfig and ethtool
right before the final halt.  According to ifconfig, eth0 is down at that
point.  According to ethtool, WoL is configured correctly ("Wake-on: g").
There is, however, a difference in the output of ethtool between the two
kernel versions.  "Link detected:" shows "yes" with 2.6.37, but "no" with
2.6.38.

A workaround that I found to work was to invoke "ifconfig eth0 up" right
before the halt.

Any suggestions?  Is this new behavior expected or is it a bug?

Kamil

-- 
Kamil Iskra  kamil@iskra.name
