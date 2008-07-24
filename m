From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL pointer dereference
Date: Thu, 24 Jul 2008 15:40:40 +0300
Message-ID: <84144f020807240540vbe7ef50uee2cacabe8016546@mail.gmail.com>
References: <20080724060448.GA10203@elte.hu>
	 <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au>
	 <20080724.022259.113079007.davem@davemloft.net>
	 <20080724093411.GA12001@elte.hu> <20080724115625.GA23994@elte.hu>
	 <20080724115957.GA25701@elte.hu> <48886FA6.6050908@trash.net>
	 <20080724122203.GA7187@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Patrick McHardy" <kaber@trash.net>, "Ingo Molnar" <mingo@elte.hu>,
	"David Miller" <davem@davemloft.net>, w@1wt.eu,
	davidn@davidnewall.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	"Dave Jones" <davej@redhat.com>, "Matt Mackall" <mpm@selenic.com>,
	"Christoph Lameter" <cl@linux-foundation.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:55975 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757479AbYGXMkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 08:40:41 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2860929rvb.1
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 05:40:41 -0700 (PDT)
In-Reply-To: <20080724122203.GA7187@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

On Thu, Jul 24, 2008 at 02:03:50PM +0200, Patrick McHardy wrote:
>> Does reverting 31d8519c fix this?

On Thu, Jul 24, 2008 at 3:22 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Regardless of whether this is the problem, banning ksize because
> it can be abused is like banning cars because they can kill people.
>
> For example, Ethernet skbs are 1500 bytes long, so using ksize
> we could potentially use the left-over memory for temporary storage.

Using ksize() for skbs will crash your kernel for some configurations
because calling that function for memory allocated with
kmem_cache_alloc() is not supported by all the allocators (well,
SLOB).

                                      Pekka
