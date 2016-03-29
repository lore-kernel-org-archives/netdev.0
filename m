From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2 net-next v3.16]r8169:  Disable set bit multicast
 enable per multicast address.
Date: Tue, 29 Mar 2016 05:59:43 -0700
Message-ID: <1459256383.6473.161.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458989821-19782-1-git-send-email-asd@marian1000.go.ro>
	 <1459012726.6473.72.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160327193150.6085df90@192-168-0-108.rdsnet.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Corcodel Marian <asd@marian1000.go.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34872 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbcC2M7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 08:59:45 -0400
Received: by mail-pa0-f47.google.com with SMTP id td3so13145454pab.2
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 05:59:45 -0700 (PDT)
In-Reply-To: <20160327193150.6085df90@192-168-0-108.rdsnet.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-03-27 at 19:31 +0300, Corcodel Marian wrote:
> On Sat, 26 Mar 2016 10:18:46 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Sat, 2016-03-26 at 12:57 +0200, Corcodel Marian wrote:
> > >  This patch correct set bit multicast enable only once per
> > > set_rx_mode invocation.
> > > 
> > > Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
> > > ---
> > >  drivers/net/ethernet/realtek/r8169.c | 3 +--
> > >  1 file changed, 1 insertion(+), 2 deletions(-)
> > > 
> > > diff --git a/drivers/net/ethernet/realtek/r8169.c
> > > b/drivers/net/ethernet/realtek/r8169.c index 7f6fb1f..f7b0dfb 100644
> > > --- a/drivers/net/ethernet/realtek/r8169.c
> > > +++ b/drivers/net/ethernet/realtek/r8169.c
> > > @@ -4619,12 +4619,11 @@ static void rtl_set_rx_mode(struct
> > > net_device *dev) } else {
> > >  		struct netdev_hw_addr *ha;
> > >  
> > > -		rx_mode = AcceptBroadcast | AcceptMyPhys;
> > > +		rx_mode = AcceptBroadcast | AcceptMyPhys |
> > > AcceptMulticast; mc_filter[1] = mc_filter[0] = 0;
> > >  		netdev_for_each_mc_addr(ha, dev) {
> > >  			int bit_nr = ether_crc(ETH_ALEN, ha->addr)
> > > >> 26; mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
> > > -			rx_mode |= AcceptMulticast;
> > >  		}
> > >  	}
> > >  
> > 
> > If the list is empty, why should we enable AcceptMulticast ?
> > 
> > 
> > 
> 
> I not experienced list empty, allways on my case exist bit_nr variable. 

If dev->mc list is empty, the netdev_for_each_mc_addr(ha, dev) does
nothing at all.

In other words, netdev_mc_count(dev) can be 0

Current code is fine, and run in control (slow) path anyway.
