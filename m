From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Fri, 30 Jan 2009 13:51:07 -0800 (PST)
Message-ID: <20090130.135107.116108989.davem@davemloft.net>
References: <20090130065721.GA4886@gondor.apana.org.au>
	<adaiqnwr91j.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, aluno3@poczta.onet.pl,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48012
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754813AbZA3VvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 16:51:09 -0500
In-Reply-To: <adaiqnwr91j.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Fri, 30 Jan 2009 09:35:52 -0800

>  > > OK, thanks... what confused me is that several other drivers also do
>  > > skb_linearize() in their hard_start_xmit method... eg bnx2x,
>  > > via-velocity, mv643xx_eth.  So there are several other lurking bugs to
>  > > deal with here I guess.
>  > 
>  > I don't know about the rest but bnx2x is certainly OK since it
>  > only does so with IRQ enabled.  It is legal to call skb_linearize
>  > as long as you're sure that IRQs are enabled, which is always the
>  > case for hard_start_xmit upon entry.
> 
> I don't believe this is accurate.  Calling skb_linearize() (on a kernel
> with CONFIG_HIGHMEM set) can end up calling local_bh_enable() in
> kunmap_skb_frag(), which can obviously cause problems if the initial
> context relies on having BHs disabled (as hard_start_xmit does).

local_bh_{enable,disable}() nests, so this is not a problem

