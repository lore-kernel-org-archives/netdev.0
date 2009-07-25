From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] fealnx: Write outside array bounds
Date: Sat, 25 Jul 2009 19:41:12 +0200
Message-ID: <4A6B43B8.3070209@gmail.com>
References: <4A699FC2.2080407@gmail.com> <Pine.LNX.4.64.0907251253350.26274@melkinkari.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:63043 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbZGYRik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 13:38:40 -0400
Received: by ewy26 with SMTP id 26so2371466ewy.37
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2009 10:38:39 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0907251253350.26274@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_idx is checked to be < 4, but np->phys[] is 2 elements long

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---

>> Or should the number of elements be increased?

>> -		for (phy = 1; phy < 32 && phy_idx < 4; phy++) {
>> +		for (phy = 1; phy < 32 && phy_idx < 2; phy++) {

> In either of the case, one should use ARRAY_SIZE(np->phys) instead of the 
> number.

Ah, yes.

diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index 48385c4..160655d 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -584,7 +584,8 @@ static int __devinit fealnx_init_one(struct pci_dev *pdev,
 	if (np->flags == HAS_MII_XCVR) {
 		int phy, phy_idx = 0;
 
-		for (phy = 1; phy < 32 && phy_idx < 4; phy++) {
+		for (phy = 1; phy < 32 && phy_idx < ARRAY_SIZE(np->phys);
+			       phy++) {
 			int mii_status = mdio_read(dev, phy, 1);
 
 			if (mii_status != 0xffff && mii_status != 0x0000) {
