From: Corcodel Marian <asd@marian1000.go.ro>
Subject: Re: [PATCH net-next v3.16]r8169: Implement definitions from
 linux/mii.h header
Date: Fri, 25 Mar 2016 16:00:21 +0200
Message-ID: <20160325160021.391d93ae@192-168-0-108.rdsnet.ro>
References: <1458901517-5932-1-git-send-email-asd@marian1000.go.ro>
	<56F524FB.5080202@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-53-82.residential.rdsnet.ro ([5.14.53.82]:58585 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbcCYOAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 10:00:47 -0400
In-Reply-To: <56F524FB.5080202@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Mar 2016 14:46:03 +0300
Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:

> Hello.
> 
> On 3/25/2016 1:25 PM, Corcodel Marian wrote:
> 
> >   Add definitions from mii and inhibit 0 to advertise.
> >
> > Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
> > ---
> >   drivers/net/ethernet/realtek/r8169.c | 22 ++++++----------------
> >   1 file changed, 6 insertions(+), 16 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/realtek/r8169.c
> > b/drivers/net/ethernet/realtek/r8169.c index a57b650..a450656 100644
> > --- a/drivers/net/ethernet/realtek/r8169.c
> > +++ b/drivers/net/ethernet/realtek/r8169.c
> > @@ -1679,29 +1679,19 @@ static int rtl8169_set_speed_xmii(struct
> > net_device *dev, int auto_nego;
> >
> >   		auto_nego = rtl_readphy(tp, MII_ADVERTISE);
> > -		auto_nego &= ~(ADVERTISE_10HALF | ADVERTISE_10FULL
> > |
> > -				ADVERTISE_100HALF |
> > ADVERTISE_100FULL); -
> > -		if (adv & ADVERTISED_10baseT_Half)
> > -			auto_nego |= ADVERTISE_10HALF;
> > -		if (adv & ADVERTISED_10baseT_Full)
> > -			auto_nego |= ADVERTISE_10FULL;
> > -		if (adv & ADVERTISED_100baseT_Half)
> > -			auto_nego |= ADVERTISE_100HALF;
> > -		if (adv & ADVERTISED_100baseT_Full)
> > -			auto_nego |= ADVERTISE_100FULL;
> > +		auto_nego &= ~(0 | ADVERTISE_10HALF |
> > ADVERTISE_10FULL |
> 
>     ORing with 0 doesn't change the result.
> 
> > +				ADVERTISE_100HALF |
> > ADVERTISE_100FULL |
> > +				ADVERTISE_PAUSE_CAP |
> > ADVERTISE_PAUSE_ASYM);
> >
> > +		auto_nego |= ethtool_adv_to_mii_adv_t(adv);
> >   		auto_nego |= ADVERTISE_PAUSE_CAP |
> > ADVERTISE_PAUSE_ASYM;
> >
> >   		giga_ctrl = rtl_readphy(tp, MII_CTRL1000);
> > -		giga_ctrl &= ~(ADVERTISE_1000FULL |
> > ADVERTISE_1000HALF);
> > +		giga_ctrl &= ~(0 | ADVERTISE_1000FULL |
> > ADVERTISE_1000HALF);
> 
>     Likewise.
> 
> [...]
> 
> MBR, Sergei
> 

>Zero not change result but is defined mii_adv_to_ethtool_adv_t,
>ethtool_adv_to_mii_ctrl1000_t and not want to set because on
>first bit from register is set on default and only 
>CSMA/CD protocol is supported.For more info see mii.h file from
>kernel
