From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH v2] net: filter: BPF 'JIT' compiler for PPC64
Date: Tue, 19 Jul 2011 17:55:35 +1000
Message-ID: <1311062135.25044.409.camel@pasglop>
References: <4E23E5C3.1070209@ozlabs.org>  <4E24E867.9050909@ozlabs.org>
	 <1311058260.16961.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matt Evans <matt@ozlabs.org>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:34373 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476Ab1GSHzp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 03:55:45 -0400
In-Reply-To: <1311058260.16961.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-07-19 at 08:51 +0200, Eric Dumazet wrote:

> > +		case BPF_S_ANC_CPU:
> > +#ifdef CONFIG_SMP
> > +			/*
> > +			 * PACA ptr is r13:
> > +			 * raw_smp_processor_id() = local_paca->paca_index
> > +			 */
> 
> This could break if one day linux supports more than 65536 cpus :)
> 
> > +			PPC_LHZ_OFFS(r_A, 13,
> > +				     offsetof(struct paca_struct, paca_index));
> > +#else
> > +			PPC_LI(r_A, 0);
> > +#endif
> > +			break;

As would our implementation of raw_smp_processor_id() and our
spinlocks :-) I don't think we need to fix that -now- but you are
welcome to add something like a
BUILD_BUG_ON(sizeof(local_paca->paca_index) != 2); as a reminder :-)

Cheers,
Ben.


