From: Ben McKeegan <ben@netservers.co.uk>
Subject: [PATCH] ppp_generic: fix multilink fragment sizes
Date: Thu,  3 Jun 2010 10:14:33 +0100
Message-ID: <1275556473-14613-1-git-send-email-ben@netservers.co.uk>
References: <DF7BB929B28FCF479E888E3D9F8D9E88D3E1706A@irsmsx502.ger.corp.intel.com>
Cc: ben@netservers.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gabriele.paoloni@intel.com,
	alan@lxorguk.ukuu.org.uk, linux-ppp@vger.kernel.org,
	paulus@samba.org
To: davem@davemloft.net
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <DF7BB929B28FCF479E888E3D9F8D9E88D3E1706A@irsmsx502.ger.corp.intel.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix bug in multilink fragment size calculation introduced by
commit 9c705260feea6ae329bc6b6d5f6d2ef0227eda0a
"ppp: ppp_mp_explode() redesign"

Signed-off-by: Ben McKeegan <ben@netservers.co.uk>
---
 drivers/net/ppp_generic.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 0db3894..c980f74 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1416,7 +1416,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		flen = len;
 		if (nfree > 0) {
 			if (pch->speed == 0) {
-				flen = totlen/nfree;
+				flen = len/nfree;
 				if (nbigger > 0) {
 					flen++;
 					nbigger--;
-- 
1.5.6.5

