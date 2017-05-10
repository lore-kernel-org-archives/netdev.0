From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] libertas: Avoid reading past end of buffer
Date: Tue, 09 May 2017 21:33:17 -0700
Message-ID: <1494390797.4564.5.camel@perches.com>
References: <20170509232334.GA55070@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
        libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
        linux-kernel@vger.kernel.org, Daniel Micay <danielmicay@gmail.com>
To: Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0189.hostedemail.com ([216.40.44.189]:40654 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751555AbdEJEdY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 00:33:24 -0400
In-Reply-To: <20170509232334.GA55070@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-09 at 16:23 -0700, Kees Cook wrote:
> Using memcpy() from a string that is shorter than the length copied means
> the destination buffer is being filled with arbitrary data from the kernel
> rodata segment. Instead, use strncpy() which will fill the trailing bytes
> with zeros. Additionally adjust indentation to keep checkpatch.pl happy.
> 
> This was found with the future CONFIG_FORTIFY_SOURCE feature.
[]
> diff --git a/drivers/net/wireless/marvell/libertas/mesh.c b/drivers/net/wireless/marvell/libertas/mesh.c
[]
> @@ -1177,9 +1177,9 @@ void lbs_mesh_ethtool_get_strings(struct net_device *dev,
>  	switch (stringset) {
>  	case ETH_SS_STATS:
>  		for (i = 0; i < MESH_STATS_NUM; i++) {
> -			memcpy(s + i * ETH_GSTRING_LEN,
> -					mesh_stat_strings[i],
> -					ETH_GSTRING_LEN);
> +			strncpy(s + i * ETH_GSTRING_LEN,
> +				mesh_stat_strings[i],
> +				ETH_GSTRING_LEN);
>  		}

The better solution is to declare
mesh_stat_strings in in the normal way

---
 drivers/net/wireless/marvell/libertas/mesh.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/marvell/libertas/mesh.c b/drivers/net/wireless/marvell/libertas/mesh.c
index d0c881dd5846..a535e7f48d2d 100644
--- a/drivers/net/wireless/marvell/libertas/mesh.c
+++ b/drivers/net/wireless/marvell/libertas/mesh.c
@@ -1108,15 +1108,15 @@ void lbs_mesh_set_txpd(struct lbs_private *priv,
  * Ethtool related
  */
 
-static const char * const mesh_stat_strings[] = {
-			"drop_duplicate_bcast",
-			"drop_ttl_zero",
-			"drop_no_fwd_route",
-			"drop_no_buffers",
-			"fwded_unicast_cnt",
-			"fwded_bcast_cnt",
-			"drop_blind_table",
-			"tx_failed_cnt"
+static const char mesh_stat_strings[][ETH_GSTRING_LEN] = {
+	"drop_duplicate_bcast",
+	"drop_ttl_zero",
+	"drop_no_fwd_route",
+	"drop_no_buffers",
+	"fwded_unicast_cnt",
+	"fwded_bcast_cnt",
+	"drop_blind_table",
+	"tx_failed_cnt",
 };
 
 void lbs_mesh_ethtool_get_stats(struct net_device *dev,
