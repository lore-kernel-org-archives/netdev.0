From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] myri10ge: small rx_done refactoring
Date: Thu, 24 Mar 2011 08:15:39 -0700
Message-ID: <20110324081539.47ad0972@nehalam>
References: <20110323124939.GA7834@redhat.com>
	<20110323083357.457f10aa@nehalam>
	<20110324081621.GA5508@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58160 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537Ab1CXPPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2011 11:15:44 -0400
In-Reply-To: <20110324081621.GA5508@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Mar 2011 09:16:21 +0100
Stanislaw Gruszka <sgruszka@redhat.com> wrote:

> On Wed, Mar 23, 2011 at 08:33:57AM -0700, Stephen Hemminger wrote:
> > On Wed, 23 Mar 2011 13:52:04 +0100
> > Stanislaw Gruszka <sgruszka@redhat.com> wrote:
> > 
> > > Add lro_enable variable to read NETIF_F_LRO flag only once per napi poll
> > > call. This should fix theoretical race condition with
> > > myri10ge_set_rx_csum() and myri10ge_set_flags() where flag NETIF_F_LRO
> > > can be changed.
> > 
> > You may need a barrier or the race may still be there.
> 
> I don't understand why barrier in that case is need.
> 
> What I tried to avoid is.
> 
> myri10ge_clean_rx_done():
> 
> if (dev->features & NETIF_F_LRO) 
> 	setup lro 
> 					myri10ge_set_flags()
> 
> if (dev->features & NETIF_F_LRO)
> 	flush lro
> 
> Now we read dev->features & NETIF_F_LRO only once to local
> lro_enabled variable. So we can not flush without setup
> or setup without flush. No idea why memory barries is still
> needed.
> 
> > The driver seems to use mb() where wmb() is intended, and never use rmb()?
> 
> Yes, I think we can have some optimalization here.
> 

Without barrier there is no guarantee that compiler read the flags
into a local variable. It is free to do the same thing as the original
code.

-- 
