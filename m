From: roopa@cumulusnetworks.com
Subject: [PATCH iproute2] bridge link: add option 'self'
Date: Thu,  4 Dec 2014 18:27:16 -0800
Message-ID: <1417746436-41023-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:38300 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933474AbaLEC1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 21:27:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Currently self is set internally only if hwmode is set.
This makes it necessary for the hw to have a mode.
There is no hwmode really required to go to hardware. So, introduce
self for anybody who wants to target hardware.
---
 bridge/link.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/bridge/link.c b/bridge/link.c
index 90d9e7f..2b86141 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -321,6 +321,9 @@ static int brlink_modify(int argc, char **argv)
 					"\"veb\".\n");
 				exit(-1);
 			}
+		} else if (strcmp(*argv, "self") == 0) {
+			NEXT_ARG();
+			flags = BRIDGE_FLAGS_SELF;
 		} else {
 			usage();
 		}
-- 
1.7.10.4
