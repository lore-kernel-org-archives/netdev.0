From: Daniel Mack <daniel@caiaq.de>
Subject: Re: [PATCH] Libertas: fix buffer overflow in lbs_get_essid()
Date: Wed, 16 Dec 2009 12:18:06 +0800
Message-ID: <20091216041805.GO28375@buzzloop.caiaq.de>
References: <1260936778-2096-1-git-send-email-daniel@caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	Holger Schurig <holgerschurig@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Maithili Hinge <maithili@marvell.com>,
	Kiran Divekar <dkiran@marvell.com>,
	Michael Hirsch <m.hirsch@raumfeld.com>, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	stable@kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:49317 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759393AbZLPESO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 23:18:14 -0500
Content-Disposition: inline
In-Reply-To: <1260936778-2096-1-git-send-email-daniel@caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Sorry, had a typo in the linux-wireless list address, corrected now).

On Wed, Dec 16, 2009 at 05:12:58AM +0100, Daniel Mack wrote:
> 
> The libertas driver copies the SSID buffer back to the wireless core and
> appends a trailing NULL character for termination. This is
> 
> a) unnecessary because the buffer is allocated with kzalloc and is hence
>    already NULLed when this function is called, and
> 
> b) for priv->curbssparams.ssid_len == 32, it writes back one byte too
>    much which causes memory corruptions.
> 
> Fix this by removing the extra write.
> 
> Signed-off-by: Daniel Mack <daniel@caiaq.de>
> Cc: Dan Williams <dcbw@redhat.com>
> Cc: Holger Schurig <holgerschurig@gmail.com>
> Cc: John W. Linville <linville@tuxdriver.com>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: Maithili Hinge <maithili@marvell.com>
> Cc: Kiran Divekar <dkiran@marvell.com>
> Cc: Michael Hirsch <m.hirsch@raumfeld.com>
> Cc: netdev@vger.kernel.org
> Cc: libertas-dev@lists.infradead.org
> Cc: linux-wireless@lists.infradead.org
> Cc: stable@kernel.org
> ---
>  drivers/net/wireless/libertas/wext.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
> index be837a0..01c738b 100644
> --- a/drivers/net/wireless/libertas/wext.c
> +++ b/drivers/net/wireless/libertas/wext.c
> @@ -1953,10 +1953,8 @@ static int lbs_get_essid(struct net_device *dev, struct iw_request_info *info,
>  	if (priv->connect_status == LBS_CONNECTED) {
>  		memcpy(extra, priv->curbssparams.ssid,
>  		       priv->curbssparams.ssid_len);
> -		extra[priv->curbssparams.ssid_len] = '\0';
>  	} else {
>  		memset(extra, 0, 32);
> -		extra[priv->curbssparams.ssid_len] = '\0';
>  	}
>  	/*
>  	 * If none, we may want to get the one that was set
> -- 
> 1.6.3.3
> 
