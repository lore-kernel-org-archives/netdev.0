From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [B.A.T.M.A.N.] [PATCH] Fix ARM BUILD_BUG_ON() errors with
	batman-adv
Date: Sat, 30 Nov 2013 23:05:18 +0000
Message-ID: <20131130230518.GC16735@n2100.arm.linux.org.uk>
References: <20131130191553.GA16735@n2100.arm.linux.org.uk> <529A46C4.9090906@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: The list for a Better Approach To Mobile Ad-hoc
	 Networking <b.a.t.m.a.n@lists.open-mesh.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:43764 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328Ab3K3XFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 18:05:40 -0500
Content-Disposition: inline
In-Reply-To: <529A46C4.9090906@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 30, 2013 at 09:12:52PM +0100, Antonio Quartulli wrote:
> I don't know the ARM architecture at all (I don't know if the other
> batman-adv developers do), so could you please provide here some more
> details about why that static check is failing? We would like to
> address this issue differently rather than re-adding the __packed
> attribute.

The reason is this struct becomes a size of 4 bytes, even though
it only contains three uint8_t members.  This offsets the members
of all structs that this struct is embedded in.

If you don't wish to fix this, then please make your subsystem
depend on !ARM because it's otherwise impossible to fix and can never
work on ARM.
