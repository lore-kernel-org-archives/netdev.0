From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Thu, 27 Mar 2008 17:02:35 -0700 (PDT)
Message-ID: <20080327.170235.53674739.davem@davemloft.net>
References: <20080327103340.GB2845@ami.dom.local>
	<36D9DB17C6DE9E40B059440DB8D95F5204C275C2@orsmsx418.amr.corp.intel.com>
	<47EC3182.7080005@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46763
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752907AbYC1ACf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 20:02:35 -0400
In-Reply-To: <47EC3182.7080005@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Thu, 27 Mar 2008 16:45:06 -0700

> Brandeburg, Jesse wrote:
> > Jarek Poplawski wrote:
> >   
> >> On Wed, Mar 26, 2008 at 01:26:00PM -0700, Matheos Worku wrote:
> >> ...
> >>     
> >>> nsn57-110 login: BUG: soft lockup - CPU#2 stuck for 11s! ... Call
> >>> Trace: [<ffffffff803ef5f6>] __skb_clone+0x24/0xdc
> >>> [<ffffffff803f152e>] skb_realloc_headroom+0x30/0x63
> >>> [<ffffffff882edd40>] :niu:niu_start_xmit+0x114/0x5af
> >>> [<ffffffff80221995>] gart_map_single+0x0/0x70
> >>> [<ffffffff803f5e2b>] dev_hard_start_xmit+0x1d2/0x246 ...
> >>>       
> >> Maybe I'm wrong with this again, but I wonder about this
> >> gart_map_single on almost all traces, and probably not supposed to be
> >> seen here. Did you try with some memory re-config/debugging?
> >>     
> >
> > I have some more examples of this but with the ixgbe driver.  We are
> > running heavy bidirectional stress with multiple rx (non-napi, yeah I
> > know) interrupts by default (and userspace irqbalance is probably on,
> > I'll have the lab try it without)
> >   
> 
> I have seen the lockup on kernels 2.6.18 and newer mostly on TX traffic. 
> I have seen it on another 10G driver (off the tree niu driver sibling, 
> nxge).  The nxge driver doesn't use any TX interrupts and I have seen it 
> with UDP TX, irqbalance disabled, with no irq activity at all.  some 
> example traces included.

Interesting.

Are you running uperf in a way such that there are multiple
processors doing TX's in parallel?  That might be a clue.
