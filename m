From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] tg3: fix VLAN tagging regression
Date: Tue, 20 Sep 2011 14:09:29 -0700
Message-ID: <20110920210929.GA9652@mcarlson.broadcom.com>
References: <4E78FC38.7040903@kasperkp.dk>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Kasper Pedersen" <kernel@kasperkp.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E78FC38.7040903@kasperkp.dk>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 20, 2011 at 01:48:56PM -0700, Kasper Pedersen wrote:
> commit 92cd3a17ce9c719abb4c28dee3438e0c641f8de4
>     tg3: Simplify tx bd assignments
> 
> broke VLAN tagging on outbound packets.
> It ifdef'ed BCM_KERNEL_SUPPORTS_8021Q, but this
> is not set anywhere. So vlan never gets set, and
> all packets are sent with vlan=0.
> 
> Change to use the CONFIG_VLAN_xxx defines instead.
> Tested on BCM5721 rev 11.
> 
> Signed-off-by: Kasper Pedersen <kernel@kasperkp.dk>

Yes.  This is correct.

Acked-by: Matt Carlson <mcarlson@broadcom.com>

> ---
>  drivers/net/tg3.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index dc3fbf6..a00d21b 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -6234,7 +6234,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		}
>  	}
>  
> -#ifdef BCM_KERNEL_SUPPORTS_8021Q
> +#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
>  	if (vlan_tx_tag_present(skb)) {
>  		base_flags |= TXD_FLAG_VLAN;
>  		vlan = vlan_tx_tag_get(skb);
> 
> 
