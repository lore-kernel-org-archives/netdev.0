From: wwguy <wey-yi.w.guy@intel.com>
Subject: Re: iwlagn regression in v3.1.5
Date: Tue, 13 Dec 2011 12:15:27 -0800
Message-ID: <1323807327.7144.6.camel@wwguy-ubuntu>
References: <4EE4AEF4.2080702@udo.edu> <4EE4DB55.4090804@udo.edu>
	 <20111211174138.79e51fe8@x220.fritz.box>  <4EE4E152.2070204@udo.edu>
	 <1323627815.1806.19.camel@wwguy-ubuntu>  <4EE50266.4050208@udo.edu>
	 <1323653737.1806.21.camel@wwguy-ubuntu>  <4EE636B9.1020305@udo.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-9adGkZalXA7a6smKi76Z"
Cc: Udo Steinberg <udo@hypervisor.org>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrej Gelenberg <andrej.gelenberg@udo.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EE636B9.1020305@udo.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-9adGkZalXA7a6smKi76Z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hi Andrej,

Could you try this patch and see any differences.

please still use the same debug flag I ask you last time.

Thanks
Wey

n Mon, 2011-12-12 at 09:15 -0800, Andrej Gelenberg wrote:
> Hi,
> 
> there are broken wlan log and working wlan log and an diff of them.
> 
> Regards,
> Andrej Gelenberg
> 
> On 12/12/2011 02:35 AM, wwguy wrote:
> > Hi Andjej,
> >
> >
> > Could you please load the module with debug=0x1082 and send me the log.
> >
> > $sudo modprobe iwlagn debug=0x1082
> >
> > Thanks
> > Wey


--=-9adGkZalXA7a6smKi76Z
Content-Disposition: attachment; filename*0=0001-iwlwifi-allow-to-switch-to-HT40-if-not-associated-ye.pat; filename*1=ch
Content-Type: text/x-patch; name="0001-iwlwifi-allow-to-switch-to-HT40-if-not-associated-ye.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 92e10223b4acf832121f0aa5b4a8d35ebb176f9e Mon Sep 17 00:00:00 2001
From: Wey-Yi Guy <wey-yi.w.guy@intel.com>
Date: Tue, 13 Dec 2011 12:13:05 -0800
Subject: [PATCH 1/1] iwlwifi: allow to switch to HT40 if not associated yet

Signed-off-by: Wey-Yi Guy <wey-yi.w.guy@intel.com>
---
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
index 36932aa..23548ac 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
@@ -610,8 +610,9 @@ int iwlagn_mac_config(struct ieee80211_hw *hw, u32 changed)
 			if (ctx->ht.enabled) {
 				/* if HT40 is used, it should not change
 				 * after associated except channel switch */
-				if (iwl_is_associated_ctx(ctx) &&
-				     !ctx->ht.is_40mhz)
+				if ((iwl_is_associated_ctx(ctx) &&
+						!ctx->ht.is_40mhz) ||
+						!iwl_is_associated_ctx(ctx))
 					iwlagn_config_ht40(conf, ctx);
 			} else
 				ctx->ht.is_40mhz = false;
-- 
1.7.0.4


--=-9adGkZalXA7a6smKi76Z--
