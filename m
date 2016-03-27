From: Corcodel Marian <asd@marian1000.go.ro>
Subject: Re: [PATCH 1/2 net-next v3.16]r8169:  Disable set bit multicast
 enable per multicast address.
Date: Sun, 27 Mar 2016 19:31:50 +0300
Message-ID: <20160327193150.6085df90@192-168-0-108.rdsnet.ro>
References: <1458989821-19782-1-git-send-email-asd@marian1000.go.ro>
	<1459012726.6473.72.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-230-247.residential.rdsnet.ro ([5.14.230.247]:44902 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbcC0QcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 12:32:15 -0400
In-Reply-To: <1459012726.6473.72.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Mar 2016 10:18:46 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Sat, 2016-03-26 at 12:57 +0200, Corcodel Marian wrote:
> >  This patch correct set bit multicast enable only once per
> > set_rx_mode invocation.
> > 
> > Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
> > ---
> >  drivers/net/ethernet/realtek/r8169.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/realtek/r8169.c
> > b/drivers/net/ethernet/realtek/r8169.c index 7f6fb1f..f7b0dfb 100644
> > --- a/drivers/net/ethernet/realtek/r8169.c
> > +++ b/drivers/net/ethernet/realtek/r8169.c
> > @@ -4619,12 +4619,11 @@ static void rtl_set_rx_mode(struct
> > net_device *dev) } else {
> >  		struct netdev_hw_addr *ha;
> >  
> > -		rx_mode = AcceptBroadcast | AcceptMyPhys;
> > +		rx_mode = AcceptBroadcast | AcceptMyPhys |
> > AcceptMulticast; mc_filter[1] = mc_filter[0] = 0;
> >  		netdev_for_each_mc_addr(ha, dev) {
> >  			int bit_nr = ether_crc(ETH_ALEN, ha->addr)
> > >> 26; mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
> > -			rx_mode |= AcceptMulticast;
> >  		}
> >  	}
> >  
> 
> If the list is empty, why should we enable AcceptMulticast ?
> 
> 
> 

I not experienced list empty, allways on my case exist bit_nr variable. 
