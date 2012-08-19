From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 1/5] drivers/net/wireless/ipw2x00/ipw2100.c: introduce
 missing initialization
Date: Sun, 19 Aug 2012 11:49:58 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1208191149400.2031@localhost6.localdomain6>
References: <1345325159-7365-1-git-send-email-Julia.Lawall@lip6.fr> <CA++WF2MmTe6WP6MQRV-v1VwkpcUrw4hU6yh79NdG-K4snzQkbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislav Yakovlev <stas.yakovlev@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA++WF2MmTe6WP6MQRV-v1VwkpcUrw4hU6yh79NdG-K4snzQkbg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

The result of one call to a function is tested, and then at the second call
to the same function, the previous result, and not the current result, is
tested again.

Also changed &bssid to bssid, at the suggestion of Stanislav Yakovlev.

The semantic match that finds the first problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression ret;
identifier f;
statement S1,S2;
@@

*ret = f(...);
if (\(ret != 0\|ret < 0\|ret == NULL\)) S1
... when any
*f(...);
if (\(ret != 0\|ret < 0\|ret == NULL\)) S2
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
v2: changed &bssid to bssid

  drivers/net/wireless/ipw2x00/ipw2100.c |    3 ++-
  1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 8a34202..534e655 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -2042,7 +2042,8 @@ static void isr_indicate_associated(struct ipw2100_priv *priv, u32 status)
  		return;
  	}
  	len = ETH_ALEN;
-	ipw2100_get_ordinal(priv, IPW_ORD_STAT_ASSN_AP_BSSID, &bssid, &len);
+	ret = ipw2100_get_ordinal(priv, IPW_ORD_STAT_ASSN_AP_BSSID, bssid,
+				  &len);
  	if (ret) {
  		IPW_DEBUG_INFO("failed querying ordinals at line %d\n",
  			       __LINE__);
