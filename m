From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH 3/5] bridge: Add missing ntohs()s for MLDv2 report parsing
Date: Wed, 16 Feb 2011 00:19:19 +0100
Message-ID: <1297811961-19249-4-git-send-email-linus.luessing@web.de>
References: <1297811961-19249-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1297811961-19249-1-git-send-email-linus.luessing@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The nsrcs number is 2 Byte wide, therefore we need to call ntohs()
before using it.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 45dcf10..e8fdaab 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1021,11 +1021,12 @@ static int br_ip6_multicast_mld2_report(struct =
net_bridge *br,
=20
 		if (!pskb_may_pull(skb,
 				   len + sizeof(*grec) +
-				   sizeof(struct in6_addr) * (*nsrcs)))
+				   sizeof(struct in6_addr) * ntohs(*nsrcs)))
 			return -EINVAL;
=20
 		grec =3D (struct mld2_grec *)(skb->data + len);
-		len +=3D sizeof(*grec) + sizeof(struct in6_addr) * (*nsrcs);
+		len +=3D sizeof(*grec) +
+		       sizeof(struct in6_addr) * ntohs(*nsrcs);
=20
 		/* We treat these as MLDv1 reports for now. */
 		switch (grec->grec_type) {
--=20
1.7.2.3
