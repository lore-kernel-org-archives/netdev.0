From: Okash Khawaja <okash.khawaja@gmail.com>
Subject: [PATCH v2 2/2] adm8211: fixed the possible pci cache line sizes
 inside switch-case
Date: Mon, 11 May 2015 12:58:31 +0100
Message-ID: <20150511115831.GA5153@bytefire-computer>
References: <20150511114104.GA4985@bytefire-computer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33211 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbbEKL6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 07:58:36 -0400
Content-Disposition: inline
In-Reply-To: <20150511114104.GA4985@bytefire-computer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCI cache line size value was being compared against decimal values
prefixed with 0x.

Fixed the literals to use the correct hex values.

This has not been tested due to lack of hardware. However, the value in 
`cline` is PCI cache line size, which is the CPU's cache line size. 
It is less likely for cache line sizes to be 22 or 50, and more likely for 
them to be 16 or 32. Also, as far as I understand, cache line size is used for
things like aligning DMA requests with CPU cache line, which improve
performance but wouldn't break anything if the value doesn't match. In
this case, we will fall through to the default case which leaves `reg`
unchanged.


Signed-off-by: Okash Khawaja <okash.khawaja@gmail.com>
---
 drivers/net/wireless/adm8211.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index 058fb4b..76c908f 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1101,10 +1101,10 @@ static void adm8211_hw_init(struct ieee80211_hw *dev)
 		case  0x8:
 			reg |= (0x1 << 14);
 			break;
-		case 0x16:
+		case 0x10:
 			reg |= (0x2 << 14);
 			break;
-		case 0x32:
+		case 0x20:
 			reg |= (0x3 << 14);
 			break;
 		default:
-- 
2.4.0
