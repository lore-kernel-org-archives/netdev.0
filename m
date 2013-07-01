From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH RFC net-next v1 1/1] net: fec: Fix RMON registers on imx6
Date: Mon, 1 Jul 2013 11:16:31 +0100
Message-ID: <51D156FF.9000503@mentor.com>
References: <jim_baxter@mentor.com> <1372432075-11629-1-git-send-email-jim_baxter@mentor.com> <9848F2DB572E5649BA045B288BE08FBE0150D3F5@039-SN2MPN1-023.039d.mgd.msft.net> <CAFXsbZpgAqvkEy+S83iJNMH9-N7h68MDRuvARE9pmT7HbcpAOQ@mail.gmail.com> <CAFXsbZoBQ3ODUnFg-VumP+YAfCJ2-d=nL_=Gk2LKXm7PadHUuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Duan Fugang-B38611 <B38611@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Li Frank-B20596 <B20596@freescale.com>,
	Joe Perches <joe@perches.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chris Healy <cphealy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:45031 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812Ab3GAKQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 06:16:37 -0400
In-Reply-To: <CAFXsbZoBQ3ODUnFg-VumP+YAfCJ2-d=nL_=Gk2LKXm7PadHUuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/06/13 04:55, Chris Healy wrote:
> On the i.MX28, I tested just setting bit 31 to 0 and not doing any of
> the clearing work and it performed correctly.  I'd suggest we just turn
> on the MIB logic in fec_restart regardless of which i.MX platform it
> is.  (Still need to not do anything if it is one of the coldfire
> platforms though.  Jim, would you like to do this our would you like me to?
> 
> Chris
> 
> 
> On Sat, Jun 29, 2013 at 3:00 PM, Chris Healy <cphealy@gmail.com
> <mailto:cphealy@gmail.com>> wrote:
> 
>     I took a look at what was going on in the various use cases with and
>     without the i.MX6x.
> 
>     The i.MX6x AND i.MX28 both have bit 29 which clears all the RMON
>     regs to zero when written to.  I was not aware of bit 29 with the
>     i.MX28 as I originally did this function for the i.MX51 and i.MX53
>     which do not have bit 29.
> 
>     Regardless, according to Andy, clearing the RMON registers in
>     fec_restart is moot as fec_restart restarts the MAC.  This being
>     true, we could probably just enable the MIB by setting bit 31 of
>     FEC_MIB_CTRLSTAT and be done.
> 
>     I have not tested this yet though.
> 
>     Chris
> 
> 
>     On Fri, Jun 28, 2013 at 10:58 PM, Duan Fugang-B38611
>     <B38611@freescale.com <mailto:B38611@freescale.com>> wrote:
> 
>         On 06/28/13 23:08, Jim Baxter wrote:
> 
>         > commit 38ae92d "fec: Add support for reading RMON registers"
>         causes the imx6Q to crash.
>         >
>         > This fixes it and clears it using the MIB Control Register's
>         MIB_CLEAR bit.
>         >
>         > Signed-off-by: Jim Baxter <jim_baxter@mentor.com
>         <mailto:jim_baxter@mentor.com>>
>         > ---
>         >  drivers/net/ethernet/freescale/fec_main.c |    8 ++++++--
>         >  1 file changed, 6 insertions(+), 2 deletions(-)
>         >
>         > diff --git a/drivers/net/ethernet/freescale/fec_main.c
>         b/drivers/net/ethernet/freescale/fec_main.c
>         > index ed6180e..a1f0413 100644
>         > --- a/drivers/net/ethernet/freescale/fec_main.c
>         > +++ b/drivers/net/ethernet/freescale/fec_main.c
>         > @@ -607,8 +607,12 @@ fec_restart(struct net_device *ndev, int
>         duplex)  #ifndef CONFIG_M5272
>         >       /* Disable, clear, and enable the MIB */
>         >       writel(1 << 31, fep->hwp + FEC_MIB_CTRLSTAT);
>         > -     for (i = RMON_T_DROP; i < IEEE_R_OCTETS_OK; i++)
>         > -             writel(0, fep->hwp + i);
>         > +     if (strcmp(id_entry->name, "imx6q-fec") == 0) {
>         > +             writel(1 << 29, fep->hwp + FEC_MIB_CTRLSTAT);
>         > +     } else {
>         > +             for (i = RMON_T_DROP; i < IEEE_R_OCTETS_OK; i++)
>         > +                     writel(0, fep->hwp + i);
>         > +     }
>         >       writel(0, fep->hwp + FEC_MIB_CTRLSTAT);  #endif
>         >
>         > --
>         > 1.7.10.4
> 
>         It is not necessary to clear MIB since fec_restart() will reset
>         MAC which cause all MAC register auto reset to  zero.
> 
> 
>         Thanks,
>         Andy
> 
> 
> 
Hi Chris,

I have submitted another patch, please check if that is what you meant?

Thank you,
Jim
