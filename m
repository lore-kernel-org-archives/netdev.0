From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] hamradio: Resolve memory leak due to missing firmware release
 in add_mcs()
Date: Thu, 6 Jan 2011 21:50:29 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101062146430.13988@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Jean-Paul Roubelat <jpr@f6fbb.org>,
	Frederic Rible <frible@teaser.fr>,
	Thomas Sailer <sailer@ife.ee.ethz.ch>
To: linux-kernel@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Failure to release_firmware() in drivers/net/hamradio/yam.c::add_mcs() 
causes memory leak.
This patch should fix it.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 yam.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

  compile tested only

diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 4e7d1d0..7d9ced0 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -396,7 +396,7 @@ static unsigned char *add_mcs(unsigned char *bits, int bitrate,
 	while (p) {
 		if (p->bitrate == bitrate) {
 			memcpy(p->bits, bits, YAM_FPGA_SIZE);
-			return p->bits;
+			goto out;
 		}
 		p = p->next;
 	}
@@ -411,7 +411,7 @@ static unsigned char *add_mcs(unsigned char *bits, int bitrate,
 	p->bitrate = bitrate;
 	p->next = yam_data;
 	yam_data = p;
-
+ out:
 	release_firmware(fw);
 	return p->bits;
 }


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

