From: "Tomas Winkler" <tomasw@gmail.com>
Subject: Re: [PATCH net-next 2/2] iwlwifi: small compile warnings without CONFIG_IWLWIFI_DEBUG
Date: Thu, 17 Jul 2008 14:08:30 +0300
Message-ID: <1ba2fa240807170408w13837d67hcfd1be50fdb07738@mail.gmail.com>
References: <1216286365-11703-1-git-send-email-den@openvz.org>
	 <1216286365-11703-2-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yi.zhu@intel.com, reinette.chatre@intel.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.186]:20660 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398AbYGQLIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 07:08:32 -0400
Received: by rn-out-0910.google.com with SMTP id k40so2031341rnd.17
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 04:08:31 -0700 (PDT)
In-Reply-To: <1216286365-11703-2-git-send-email-den@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2008 at 12:19 PM, Denis V. Lunev <den@openvz.org> wrote:
> CC [M]  drivers/net/wireless/iwlwifi/iwl-4965-rs.o
> drivers/net/wireless/iwlwifi/iwl-4965-rs.c: In function 'rs_clear':
> drivers/net/wireless/iwlwifi/iwl-4965-rs.c:2405: warning: unused variable 'priv'
> CC [M]  drivers/net/wireless/iwlwifi/iwl-scan.o
> drivers/net/wireless/iwlwifi/iwl-scan.c: In function 'iwl_rx_scan_complete_notif':
> drivers/net/wireless/iwlwifi/iwl-scan.c:274: warning: unused variable 'scan_notif'
>
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> ---
>  drivers/net/wireless/iwlwifi/iwl-4965-rs.c |    2 ++
>  drivers/net/wireless/iwlwifi/iwl-scan.c    |    2 ++
>  2 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/wireless/iwlwifi/iwl-4965-rs.c b/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
> index 3ccb84a..7549834 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
> @@ -2402,7 +2402,9 @@ static void rs_free(void *priv_rate)
>
>  static void rs_clear(void *priv_rate)
>  {
> +#ifdef CONFIG_IWLWIFI_DEBUG
>        struct iwl_priv *priv = (struct iwl_priv *) priv_rate;
> +#endif
>
>        IWL_DEBUG_RATE("enter\n");

move #endif after debug print

>
> diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
> index efc750d..5d0d70c 100644
> --- a/drivers/net/wireless/iwlwifi/iwl-scan.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
> @@ -270,8 +270,10 @@ static void iwl_rx_scan_results_notif(struct iwl_priv *priv,
>  static void iwl_rx_scan_complete_notif(struct iwl_priv *priv,
>                                       struct iwl_rx_mem_buffer *rxb)
>  {
> +#ifdef CONFIG_IWLWIFI_DEBUG
>        struct iwl_rx_packet *pkt = (struct iwl_rx_packet *)rxb->skb->data;
>        struct iwl_scancomplete_notification *scan_notif = (void *)pkt->u.raw;
> +#endif
>
>        IWL_DEBUG_SCAN("Scan complete: %d channels (TSF 0x%08X:%08X) - %d\n",
>                       scan_notif->scanned_channels,
move #endif after debug print
> --
> 1.5.4.5

Strange, I have this #ifdefs in my code. Probably missed to publish some patch.
Tomas
