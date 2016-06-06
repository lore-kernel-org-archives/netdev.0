From: Bert Kenward <bkenward@solarflare.com>
Subject: Re: [PATCH net] ethernet/sfc: report supported link speeds on SFP
 connections
Date: Mon, 6 Jun 2016 16:07:35 +0100
Message-ID: <425d6ed8-32ef-de58-6452-3a989bf93517@solarflare.com>
References: <1464917604-11596-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	"Edward Cree" <ecree@solarflare.com>, <netdev@vger.kernel.org>
To: Jarod Wilson <jarod@redhat.com>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464917604-11596-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Apologies for delay in replying.

On 03/06/16 02:33, Jarod Wilson wrote:
> My solarflare cards connected to a 10GbE switch with an SFP+ module/cable
> don't currently report any supported link speeds:
>
> ...
> 
> diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
> index 7f295c4..6516471 100644
> --- a/drivers/net/ethernet/sfc/mcdi_port.c
> +++ b/drivers/net/ethernet/sfc/mcdi_port.c
> @@ -189,6 +189,10 @@ static u32 mcdi_to_ethtool_cap(u32 media, u32 cap)
>  
>  	case MC_CMD_MEDIA_XFP:
>  	case MC_CMD_MEDIA_SFP_PLUS:
> +		if (cap & (1 << MC_CMD_PHY_CAP_1000FDX_LBN))
> +			result |= SUPPORTED_1000baseKX_Full;
> +		if (cap & (1 << MC_CMD_PHY_CAP_10000FDX_LBN))
> +			result |= SUPPORTED_10000baseKX4_Full;

We probably shouldn't be claiming KX/KX4 here, because it isn't. I'll post an
updated patch shortly.

Bert.
