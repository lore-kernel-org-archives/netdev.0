From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH nf next 0/3] bridge: netfilter: fix handling of ipv4
 packets w. options
Date: Sat, 4 Oct 2014 21:55:08 +0800
Message-ID: <20141004135508.GA10705@gondor.apana.org.au>
References: <1412384670-17794-1-git-send-email-fw@strlen.de>
 <20141004035606.GA8228@gondor.apana.org.au>
 <20141004100413.GA1241@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, bsd@redhat.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, davidn@davidnewall.com,
	Bandan Das <bandan.das@stratus.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141004100413.GA1241@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 04, 2014 at 12:04:13PM +0200, Florian Westphal wrote:
>
> > The reason I asked for the IPCB to be built is to handle exactly
> > that case.
> 
> Why do we need to compile ip options, exactly?  If the packet
> is locally delivered, we hand it up to the ip stack which will
> compile ip options normally.

Good point.  I thought we added this because Bandan Das wanted
options.  But rereading the thread in question

	http://lkml.org/lkml/2010/9/3/16

it seems that he doesn't actually need options.  So what happened
appears to be a misunderstanding.  Bandan tried to improve my
original memset hack by compiling options which would have been
fine except that his approach ended up mangling the packet which
is a big no-no.

So the most straightforward solution is to go back to my original
hack and just do a straight memset zero of the cb area before
each entry into the IP stack from the bridge.

I'll try to create a patch that essentially reverts the patch
that led us here.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
