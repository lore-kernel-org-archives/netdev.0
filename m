From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH 1/3] driver: net: ethernet: cpsw: implement ethtool get/set phy setting
Date: Thu, 07 Mar 2013 19:49:30 +0100
Message-ID: <87txon3v0l.fsf@dell.be.48ers.dk>
References: <1362659421-11884-1-git-send-email-mugunthanvnm@ti.com>
	<1362659421-11884-2-git-send-email-mugunthanvnm@ti.com>
	<8762135on4.fsf@dell.be.48ers.dk> <5138CAA8.1060106@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:65535 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759242Ab3CGStg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 13:49:36 -0500
In-Reply-To: <5138CAA8.1060106@ti.com> (Mugunthan V. N.'s message of "Thu, 7
	Mar 2013 22:43:12 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Mugunthan" == Mugunthan V N <mugunthanvnm@ti.com> writes:

Hi,

 M> +- ethtool-active-slave	: Specifies the slave to use for ethtool command
 >> 
 >> That again sounds like something Linux specific rather than a hardware
 >> property.
 >> 
 >> It would be good if all these special things (dual emac mode, vlan
 >> handling, switching) could be handled using the existing kernel
 >> (bridging/vlan) infrastructure, and the driver always just exposing 2
 >> network interfaces instead of these configuration properties.

 Mugunthan> Switch and Dual Emac modes of operation of CPSW are two
 Mugunthan> different features of the hardware and packet routing
 Mugunthan> between the slaves in the hardware are different in both the
 Mugunthan> modes.

 Mugunthan> If by default it is brought up as Dual EMAC then hardware
 Mugunthan> switching is blocked and use-cases like IP phone etc cannot
 Mugunthan> be achieved.

Well, you could use the (sw) bridge functionality of the kernel network
stack, but performance naturally wouldn't be as good.

 Mugunthan> Since CPSW as a hardware Switch, it cannot not be handled in
 Mugunthan> existing kernel feature.

Well, we do have net/dsa, which is conceptually quite similar (even
though it has never been extended to hook into the bridging stuff). I
agree that we don't have infrastructure to handle hw like cpsw in a
really good way today, but it would be very nice to move towards it.

-- 
Bye, Peter Korsgaard
