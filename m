From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: [BUGS] [CHECKER] 99 synchronization bugs and a lock summary
 database
Date: Fri, 2 Jul 2004 12:30:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040702123022.563ee931.akpm@osdl.org>
References: <20040702004956.448c95d9.akpm@osdl.org>
	<E1BgLql-00055X-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1BgLql-00055X-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> Andrew Morton <akpm@osdl.org> wrote:
> > 
> > Could someone please take a look at the locking in
> > net/ipv4/ipmr.c:ipmr_mfc_seq_next?  It seems rather broken.
> 
> Obfuscated yes, broken no.

Really?  Even if that goto

	if (it->cache == &mfc_unres_queue) 
		goto end_of_list;

is taken?

Bizarre.  It sure looks wrong.  But then, if the author couldn't be
bothered describing the locking, I can't be bothered reverse engineering
it, so there.

>  Unfortunately the seq interface tends to produce code like this.

Maybe.  It could be that the locking in there is straightforward and
sensible.  But because it is also secretly designed, we see what happens -
it wasted the Stanford guys' time, my time, your time, etc.

Sigh.
