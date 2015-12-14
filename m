From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ravb: Add disable 10base
Date: Mon, 14 Dec 2015 13:53:04 +0900
Message-ID: <20151214045301.GA18143@verge.net.au>
References: <1450019758-32710-1-git-send-email-ykaneko0929@gmail.com>
 <566DA83C.9080801@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <566DA83C.9080801@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Cc Florian]

On Sun, Dec 13, 2015 at 08:17:48PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 12/13/2015 06:15 PM, Yoshihiro Kaneko wrote:
> 
> >From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> >
> >Ethernet AVB does not support 10 Mbps transfer speed.
> >
> >Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> >Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> >---
> >
> >This patch is based on the master branch of David Miller's networking
> >tree.
> >
> >  drivers/net/ethernet/renesas/ravb_main.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> >diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> >index b69e0c2..467d416 100644
> >--- a/drivers/net/ethernet/renesas/ravb_main.c
> >+++ b/drivers/net/ethernet/renesas/ravb_main.c
> >@@ -905,6 +905,9 @@ static int ravb_phy_init(struct net_device *ndev)
> >  		netdev_info(ndev, "limited PHY to 100Mbit/s\n");
> >  	}
> >
> >+	/* 10BASE is not supported */
> >+	phydev->supported &= ~PHY_10BT_FEATURES;
> >+
> 
>    Perhaps we need phy_set_min_speed() in addition to phy_set_max_speed()?

FWIW, as the person who added phy_set_max_speed(), I think
that is sounds like a good idea.
