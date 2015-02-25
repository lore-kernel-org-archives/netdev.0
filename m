From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] e1000: add dummy allocator to fix race condition
 between mtu change and netpoll
Date: Wed, 25 Feb 2015 11:45:40 +0100
Message-ID: <20150225104540.GA26358@kria>
References: <1424858711-22879-1-git-send-email-sd@queasysnail.net>
 <1424860005.5565.88.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jeffrey.t.kirsher@intel.com, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:9292 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752942AbbBYKpq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 05:45:46 -0500
Content-Disposition: inline
In-Reply-To: <1424860005.5565.88.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-02-25, 02:26:45 -0800, Eric Dumazet wrote:
> On Wed, 2015-02-25 at 11:05 +0100, Sabrina Dubroca wrote:
> > There is a race condition between e1000_change_mtu's cleanups and
> > netpoll, when we change the MTU across jumbo size:
> ...
> > 
> > Fixes: edbbb3ca1077 ("e1000: implement jumbo receive with partial descriptors")
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > ---
> >  drivers/net/ethernet/intel/e1000/e1000_main.c | 14 +++++++++++++-
> >  1 file changed, 13 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> > index 7f997d36948f..5af866150671 100644
> > --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> > +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> > @@ -144,6 +144,9 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
> >  static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
> >  				     struct e1000_rx_ring *rx_ring,
> >  				     int *work_done, int work_to_do);
> > +static void e1000_alloc_dummy_rx_buffers(struct e1000_adapter *adapter,
> > +					 struct e1000_rx_ring *rx_ring,
> > +					 int cleaned_count);
> 
> Why are you using a forward declaration ?
> 
> Simply put here the body of this (dummy) function.

I wanted to match the style for the other allocators.  I'll send a v2.


Thanks,
-- 
Sabrina
