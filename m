From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH v2 3/3] ipgre: capture inner headers during
 encapsulation
Date: Wed, 14 Nov 2012 12:32:39 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F1BF5CF1C@SJEXCHMB06.corp.ad.broadcom.com>
References: <1352689450-4092-1-git-send-email-joseph.gasparakis@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Peter P Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>
To: "Joseph Gasparakis" <joseph.gasparakis@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"chrisw@sous-sol.org" <chrisw@sous-sol.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352689450-4092-1-git-send-email-joseph.gasparakis@intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Joseph Gasparakis
> Sent: Monday, November 12, 2012 5:04 AM
> To: davem@davemloft.net; shemminger@vyatta.com; chrisw@sous-sol.org
> Cc: Joseph Gasparakis; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> Peter P Waskiewicz Jr
> Subject: [PATCH v2 3/3] ipgre: capture inner headers during encapsulation
> 
> Populating the inner header pointers of skb for ipgre
> This patch has been compile-tested only.
> 
> v2 Makes sure that checksumming does not take place if the offload flag is set in
> the skb's netdev features
> 
> Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> ---
>  net/ipv4/ip_gre.c | 15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 7240f8e..e35ed52 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -766,8 +766,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff
> *skb, struct net_device *dev
>  	int    gre_hlen;
>  	__be32 dst;
>  	int    mtu;
> +	unsigned int offset;
> 
> -	if (skb->ip_summed == CHECKSUM_PARTIAL &&
> +	if (!(skb->dev->features & NETIF_F_HW_CSUM_ENC_BIT) &&

 You should test for NETIF_F_HW_CSUM_ENC and not for NETIF_F_HW_CSUM_ENC_BIT
