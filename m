From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] rt2x00: Use kcalloc instead of kzalloc to allocate array
Date: Tue, 29 Nov 2011 22:08:00 +0100
Message-ID: <1322600880.1534.325.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: IvDoorn@gmail.com, gwingerde@gmail.com,
	helmut.schaa@googlemail.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The advantage of kcalloc is, that will prevent integer overflows which could
result from the multiplication of number of elements and size and it is also
a bit nicer to read.

The semantic patch that makes this change is available
in https://lkml.org/lkml/2011/11/25/107

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c 2011-11-28 19:36:47.770108588 +0100
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c 2011-11-28 19:54:53.495525543 +0100
@@ -831,11 +831,11 @@ static int rt2x00lib_probe_hw_modes(stru
 	if (spec->supported_rates & SUPPORT_RATE_OFDM)
 		num_rates += 8;
 
-	channels = kzalloc(sizeof(*channels) * spec->num_channels, GFP_KERNEL);
+	channels = kcalloc(spec->num_channels, sizeof(*channels), GFP_KERNEL);
 	if (!channels)
 		return -ENOMEM;
 
-	rates = kzalloc(sizeof(*rates) * num_rates, GFP_KERNEL);
+	rates = kcalloc(num_rates, sizeof(*rates), GFP_KERNEL);
 	if (!rates)
 		goto exit_free_channels;
 
