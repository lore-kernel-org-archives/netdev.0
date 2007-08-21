From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: don't clear phy power bits
Date: Tue, 21 Aug 2007 11:10:22 -0700
Message-ID: <20070821111022.046eec14@freepuppy.rosehill.hemminger.net>
References: <20070821064251.972690753@blue.kroah.org>
	<20070821065421.GG5275@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, stable@kernel.org,
	Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41964 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761182AbXHUSUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 14:20:06 -0400
In-Reply-To: <20070821065421.GG5275@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are special PHY settings available on Yukon EC-U chip that
should not get cleared. This should solve mysterious errors on some
motherboards (like Gigabyte DS-3).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-08-21 11:08:27.000000000 -0700
+++ b/drivers/net/sky2.c	2007-08-21 11:09:03.000000000 -0700
@@ -657,8 +657,8 @@ static void sky2_mac_init(struct sky2_hw
 	int i;
 	const u8 *addr = hw->dev[port]->dev_addr;
 
-	sky2_write32(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);
-	sky2_write32(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
+	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);
+	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
 
 	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_CLR);
 
