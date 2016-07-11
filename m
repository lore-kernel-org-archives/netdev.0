From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: NACK: [PATCH] nfp: check idx is -ENOSPC before using it is an index
Date: Mon, 11 Jul 2016 16:52:02 +0100
Message-ID: <5783C0A2.2020405@canonical.com>
References: <1468252017-14864-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
	Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Rolf Neugebauer <rolf.neugebauer-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
	Christophe Ricard <christophe.ricard-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Robert Dolca <robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	oss-drivers-wFxRvT7yatFl57MIdRCFDg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1468252017-14864-1-git-send-email-colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ignore this, got some other fix included by mistake. Will resend.

On 11/07/16 16:46, Colin King wrote:
> From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> idx can be returned as -ENOSPC, so we should check for this first
> before using it as an index into nn->vxlan_usecnt[] to avoid an
> out of bounds array offset read.
> 
> Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 2 +-
>  drivers/nfc/fdp/fdp.c                               | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> index 1e74b91..88678c1 100644
> --- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> +++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> @@ -2578,7 +2578,7 @@ static void nfp_net_del_vxlan_port(struct net_device *netdev,
>  		return;
>  
>  	idx = nfp_net_find_vxlan_idx(nn, ti->port);
> -	if (!nn->vxlan_usecnt[idx] || idx == -ENOSPC)
> +	if (idx == -ENOSPC || !nn->vxlan_usecnt[idx])
>  		return;
>  
>  	if (!--nn->vxlan_usecnt[idx])
> diff --git a/drivers/nfc/fdp/fdp.c b/drivers/nfc/fdp/fdp.c
> index e44a7a2..d93d314 100644
> --- a/drivers/nfc/fdp/fdp.c
> +++ b/drivers/nfc/fdp/fdp.c
> @@ -345,7 +345,7 @@ static void fdp_nci_release_firmware(struct nci_dev *ndev)
>  
>  	if (info->ram_patch) {
>  		release_firmware(info->ram_patch);
> -		info->otp_patch = NULL;
> +		info->ram_patch = NULL;
>  	}
>  }
>  
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
