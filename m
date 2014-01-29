From: Dave Jones <davej@redhat.com>
Subject: [rfc] b43: possible missing break in b43_wa_all
Date: Wed, 29 Jan 2014 12:35:48 -0500
Message-ID: <20140129173548.GA18873@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stefano.brivio@polimi.it
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751241AbaA2RgA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jan 2014 12:36:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm going through all the 'missing break in switch' bugs in coverity, and
most of them look like intentional/false positives, but this one looks odd to me.

It seems the intent is to B43_WARN_ON only if we don't know the phy, so it seems
strange to do it after we've just initialized type 7.

If this is agreed to be a bug, I'll submit the below patch properly,
but I want to be sure this isn't something like "type 7 is work in progress"
It's been this way since 2007 though. I guess no-one runs with CONFIG_B43_DEBUG on.

	Dave

diff --git a/drivers/net/wireless/b43/wa.c b/drivers/net/wireless/b43/wa.c
index 9b1a038be08b..47f0ec887e1f 100644
--- a/drivers/net/wireless/b43/wa.c
+++ b/drivers/net/wireless/b43/wa.c
@@ -587,6 +587,7 @@ void b43_wa_all(struct b43_wldev *dev)
 			b43_wa_txpuoff_rxpuon(dev);
 			b43_wa_txlna_gain(dev);
 			b43_wa_rssi_adc(dev);
+			break;
 		default:
 			B43_WARN_ON(1);
 		}
