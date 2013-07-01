From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH net-next v1 1/1] net: fec: Fix RMON registers on imx6
Date: Mon, 1 Jul 2013 14:52:59 +0100
Message-ID: <51D189BB.5030601@mentor.com>
References: <jim_baxter@mentor.com> <1372674719-6525-1-git-send-email-jim_baxter@mentor.com> <CAFXsbZoDWn4KgAVEpUtajo+PwfnrJoO0eTw9g6+MdQ8b666=EQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>,
	Joe Perches <joe@perches.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chris Healy <cphealy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:64137 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100Ab3GANxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 09:53:04 -0400
In-Reply-To: <CAFXsbZoDWn4KgAVEpUtajo+PwfnrJoO0eTw9g6+MdQ8b666=EQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/13 14:42, Chris Healy wrote:
> The comment one line up should change to reflect the functional change. 
> Something like:  "Enable the MIB logic"
> 
> 
> On Mon, Jul 1, 2013 at 3:31 AM, Jim Baxter <jim_baxter@mentor.com
> <mailto:jim_baxter@mentor.com>> wrote:
> 
>     commit 38ae92d "fec: Add support for reading
>     RMON registers" causes the imx6Q to crash.
> 
>     This fixes it by only enabling the RMON registers, the
>     registers are already cleared by the MAC being reset.
> 
>     Signed-off-by: Jim Baxter <jim_baxter@mentor.com
>     <mailto:jim_baxter@mentor.com>>
>     ---
>     Change v1 to v2
>     Removed per processor change and just set bit 31 to 0.
> 
>      drivers/net/ethernet/freescale/fec_main.c |    5 +----
>      1 file changed, 1 insertion(+), 4 deletions(-)
> 
>     diff --git a/drivers/net/ethernet/freescale/fec_main.c
>     b/drivers/net/ethernet/freescale/fec_main.c
>     index ed6180e..c772df1 100644
>     --- a/drivers/net/ethernet/freescale/fec_main.c
>     +++ b/drivers/net/ethernet/freescale/fec_main.c
>     @@ -606,10 +606,7 @@ fec_restart(struct net_device *ndev, int duplex)
> 
>      #ifndef CONFIG_M5272
>             /* Disable, clear, and enable the MIB */
>     -       writel(1 << 31, fep->hwp + FEC_MIB_CTRLSTAT);
>     -       for (i = RMON_T_DROP; i < IEEE_R_OCTETS_OK; i++)
>     -               writel(0, fep->hwp + i);
>     -       writel(0, fep->hwp + FEC_MIB_CTRLSTAT);
>     +       writel(0 << 31, fep->hwp + FEC_MIB_CTRLSTAT);
>      #endif
> 
>             /* And last, enable the transmit and receive processing */
>     --
>     1.7.10.4
> 
> 

Hi Chris,
Does "Enable the MIB statistic event counters" sound OK?

Thank you,
Jim
