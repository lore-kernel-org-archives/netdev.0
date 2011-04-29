From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 2/2] tg3: Add code to allow ethtool to
 enable/disable loopback.
Date: Thu, 28 Apr 2011 19:23:37 -0700
Message-ID: <20110429022337.GA20805@mcarlson.broadcom.com>
References: <1304033599-8395-1-git-send-email-maheshb@google.com>
 <1304033599-8395-2-git-send-email-maheshb@google.com>
 <1304033599-8395-3-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	netdev <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"Micha? Miros?aw" <mirq-linux@rere.qmqm.pl>
To: "Mahesh Bandewar" <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1170 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756741Ab1D2CKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2011 22:10:24 -0400
In-Reply-To: <1304033599-8395-3-git-send-email-maheshb@google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2011 at 04:33:19PM -0700, Mahesh Bandewar wrote:
> ---
>  drivers/net/tg3.c |   32 ++++++++++++++++++++++++++++++++
>  1 files changed, 32 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index fa57e3d..208884d 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -6319,6 +6319,33 @@ static u32 tg3_fix_features(struct net_device *dev, u32 features)
>  	return features;
>  }
>  
> +static int tg3_set_features(struct net_device *dev, u32 features)
> +{
> +	struct tg3 *tp = netdev_priv(dev);
> +	u32 cur_mode = 0;
> +	int err = 0;
> +
> +	spin_lock_bh(&tp->lock);
> +	cur_mode = tr32(MAC_MODE);
> +
> +	if (features & NETIF_F_LOOPBACK) {
> +		/* Enable internal MAC loopback mode */
> +		tw32(MAC_MODE, cur_mode | MAC_MODE_PORT_INT_LPBACK);

I didn't notice this before, but you will want to clear
MAC_MODE_HALF_DUPLEX when going into loopback mode.  You won't get
packets back if you happen to negotiate to HD.


