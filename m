From: Jeff Layton <jeff.layton@primarydata.com>
Subject: Re: [PATCH] net: clean up some sparse endianness warnings in ipv6.h
Date: Tue, 15 Jul 2014 13:17:16 -0400
Message-ID: <20140715131716.7e14c493@tlielax.poochiereds.net>
References: <1405340746-10678-1-git-send-email-jlayton@primarydata.com>
	<20140715170107.GA1722@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140715170107.GA1722@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2014 10:01:07 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> >  #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
> > -	const unsigned long *ul = (const unsigned long *)a;
> > +	const __be64 *be = (const __be64 *)a;
> >  
> > -	return (ul[0] | (ul[1] ^ cpu_to_be64(1))) == 0UL;
> > +	return (be[0] | (be[1] ^ cpu_to_be64(1))) == cpu_to_be64(0UL);
> 
> Do you need the swap for 0UL?  I know sparse treats 0 as special, so why
> wouldn't it treat 0UL special?  Or just remove the 0UL postfix, no need
> for it in a simple comparism.
> 
> Otherwise looks fine to me.

Maybe not, I did it for completeness sake. I'll see if I can remove
that. The macros do the conversion at compile time though so it
shouldn't hurt anything either way.

-- 
Jeff Layton <jlayton@primarydata.com>
