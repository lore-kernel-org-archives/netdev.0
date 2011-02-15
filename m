From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH 2/5] bridge: Fix IPv6 multicast snooping by correcting offset in MLDv2 report
Date: Wed, 16 Feb 2011 00:19:18 +0100
Message-ID: <1297811961-19249-3-git-send-email-linus.luessing@web.de>
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

We actually want a pointer to the grec_nsrcr and not the following
field. Otherwise we can get very high values for *nsrcs as the first tw=
o
bytes of the IPv6 multicast address are being used instead, leading to
a failing pskb_may_pull() which results in MLDv2 reports not being
parsed.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 135d929..45dcf10 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1014,7 +1014,7 @@ static int br_ip6_multicast_mld2_report(struct ne=
t_bridge *br,
=20
 		nsrcs =3D skb_header_pointer(skb,
 					   len + offsetof(struct mld2_grec,
-							  grec_mca),
+							  grec_nsrcs),
 					   sizeof(_nsrcs), &_nsrcs);
 		if (!nsrcs)
 			return -EINVAL;
--=20
1.7.2.3
