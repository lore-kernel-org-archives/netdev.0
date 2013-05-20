From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] x86: bpf_jit_comp: secure bpf jit against
 spraying attacks
Date: Mon, 20 May 2013 16:19:41 +0200
Message-ID: <20130520141941.GA16412@breakpoint.cc>
References: <1368844623.3301.142.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:35107 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756308Ab3ETOTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 10:19:53 -0400
Content-Disposition: inline
In-Reply-To: <1368844623.3301.142.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> hpa bringed into my attention some security related issues
> with BPF JIT on x86.
> 
> This patch makes sure the bpf generated code is marked read only,
> as other kernel text sections.
> 
> It also splits the unused space (we vmalloc() and only use a fraction of
> the page) in two parts, so that the generated bpf code not starts at a
> known offset in the page, but a pseudo random one.
> 
> Refs:
> http://mainisusuallyafunction.blogspot.com/2012/11/attacking-hardened-linux-systems-with.html

What about emitting additional instructions at random locations in the
generated code itself?

Eg., after every instruction, have random chance to insert
'xor $0xcc,%al; xor $0xcc,%al', etc?
