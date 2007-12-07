From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.24-rc4-mm1
Date: Fri, 7 Dec 2007 15:16:49 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712061146120.28055@kivilampi-30.cs.helsinki.fi>
References: <20071204211701.994dfce6.akpm@linux-foundation.org>
 <47579DD9.9030909@reub.net> <20071205.230925.99250129.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, auke-jan.h.kok@intel.com,
	David Miller <davem@davemloft.net>
To: reuben-linuxkernel@reub.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40362 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbXLGNQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 08:16:51 -0500
In-Reply-To: <20071205.230925.99250129.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Dec 2007, David Miller wrote:

> From: Reuben Farrelly <reuben-linuxkernel@reub.net>
> Date: Thu, 06 Dec 2007 17:59:37 +1100
> 
> > On 5/12/2007 4:17 PM, Andrew Morton wrote:
> > > - Lots of device IDs have been removed from the e1000 driver and moved over
> > >   to e1000e.  So if your e1000 stops working, you forgot to set CONFIG_E1000E.
> > 
> > This non fatal oops which I have just noticed may be related to this change then 
> > - certainly looks networking related.
> > 
> > WARNING: at net/ipv4/tcp_input.c:2518 tcp_fastretrans_alert()
> > Pid: 0, comm: swapper Not tainted 2.6.24-rc4-mm1 #1
> > 
> > Call Trace:
> >   <IRQ>  [<ffffffff8046e038>] tcp_fastretrans_alert+0x229/0xe63
> >   [<ffffffff80470975>] tcp_ack+0xa3f/0x127d
> >   [<ffffffff804747b7>] tcp_rcv_established+0x55f/0x7f8
> >   [<ffffffff8047b1aa>] tcp_v4_do_rcv+0xdb/0x3a7
> >   [<ffffffff881148a8>] :nf_conntrack:nf_ct_deliver_cached_events+0x75/0x99
> 
> No, it's from TCP assertions and changes added by Ilpo to the
> net-2.6.25 tree recently.

Yeah, this (very likely) due to the new SACK processing (in net-2.6.25). 
I'll look what could go wrong with fack_count calculations, most likely 
it's the reason (I've found earlier one out-of-place retransmission 
segment in one of my test case which already indicated that there's 
something incorrect with them but didn't have time to debug it yet).

Thanks for report. Some info about how easily you can reproduce & 
couple of sentences about the test case might be useful later on when 
evaluating the fix.

-- 
 i.
