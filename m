From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: r8169: remove "PHY reset until link up" log spam
Date: Tue, 23 Jul 2013 18:07:15 +0200
Message-ID: <2856794.AWy189S2qk@al>
References: <4961229.bXDGvH0dpz@al> <20130723085436.70e8588c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nic_swsd@realtek.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:57543 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932964Ab3GWQHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 12:07:20 -0400
Received: by mail-ea0-f170.google.com with SMTP id h10so4579036eaj.15
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 09:07:19 -0700 (PDT)
In-Reply-To: <20130723085436.70e8588c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 23 July 2013 08:54:36 Stephen Hemminger wrote:
> On Tue, 23 Jul 2013 11:55:57 +0200
> 
> Peter Wu <lekensteyn@gmail.com> wrote:
> > This message was added in commit a7154cb8 (June 2004) and is printed
> > every ten seconds when no cable is connected.
> > 
> > Signed-off-by: Peter Wu <lekensteyn@gmail.com>
> > ---
> > Using ethtool to silence *all* link warnings is still a manual
> > operation, in my opinion not acceptable so let's remove this message.
> > 
> > The r8169 constantly resets the device when no link is connected,
> > contrary the r8168 vendor driver which only resets the link when some
> > PCI config fields have been modified. As the current reset logic in r8168
> > seems to work for broken device (which I do not have have and therefore
> > cannot test), I did not attempt to "clean this up".
> > ---
> > 
> >  drivers/net/ethernet/realtek/r8169.c | 2 --
> >  1 file changed, 2 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/realtek/r8169.c
> > b/drivers/net/ethernet/realtek/r8169.c index 880015c..63f04af 100644
> > --- a/drivers/net/ethernet/realtek/r8169.c
> > +++ b/drivers/net/ethernet/realtek/r8169.c
> > @@ -3689,8 +3689,6 @@ static void rtl_phy_work(struct rtl8169_private *tp)
> > 
> >  	if (tp->link_ok(ioaddr))
> >  	
> >  		return;
> > 
> > -	netif_warn(tp, link, tp->dev, "PHY reset until link up\n");
> > -
> > 
> >  	tp->phy_reset_enable(tp);
> >  
> >  out_mod_timer:
> Why not implement netif msg flag to allow user to control this?

Which user wants to get log spam every ten seconds? I see no purpose except 
when a developer asks a user to turn this on, or except if you are a 
developer. This message was added almost ten years ago, Realtek must certainly 
have improved their hardware not to be so crappy? 

See also <http://marc.info/?l=linux-netdev&m=137452974325684&w=2> where David 
Miller wrote:
> In every case where this issue has popped up, we have decided that
> printing messages when the cable is simply unplugged is very
> undesirable.

Regards,
Peter
