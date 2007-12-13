From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 15:14:41 +0100
Message-ID: <20071213141441.GB3806@ff.dom.local>
References: <47602B77.2090202@intel.com> <20071213134953.GA3806@ff.dom.local> <20071213.055013.83963139.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: auke-jan.h.kok@intel.com, gallatin@myri.com, joonwpark81@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:1365 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753071AbXLMOJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 09:09:40 -0500
Received: by nf-out-0910.google.com with SMTP id g13so569604nfb.21
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 06:09:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20071213.055013.83963139.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2007 at 05:50:13AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 13 Dec 2007 14:49:53 +0100
> 
> > As a matter of fact, since it's "unlikely()" in net_rx_action() anyway,
> > I wonder what is the main reason or gain of leaving such a tricky
> > exception, instead of letting drivers to always decide which is the
> > best moment for napi_complete()? (Or maybe even, in such a case, they
> > should call some function with this list_move_tail() if it's so
> > useful?)
> 
> It is the only sane way to synchronize the list manipulations.
> 
> There has to be a way for ->poll() to tell net_rx_action() two things:
> 
> 1) How much work was completed, so we can adjust 'budget'
> 2) Was the NAPI quota exhausted?  So that we know that
>    net_rx_action() still "owns" the polling context and
>    thus can do the list manipulation safely.
> 
> And these both need to be encoded into one single return value, thus
> the adopted convention that "work == weight" means that the device has
> not done a NAPI complete.

Thanks! So, I've to rethink this all...

Jarek P.
