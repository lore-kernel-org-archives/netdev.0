From: "David S. Miller" <davem@redhat.com>
Subject: Re: [CRYPTO] Fix stack overrun in crypt()
Date: Wed, 21 Jul 2004 15:02:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040721150219.18b7b1f9.davem@redhat.com>
References: <20040715114840.GA1325@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040715114840.GA1325@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jul 2004 21:48:40 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> PS I think someone should double-check the logic in the scatterwalk
> stuff, especially the whichbuf bits.

The goal of scatterwalk_whichbuf() is to use the temporary buffer
if we are walking over a page boundary.

We can use walk->data, and thus directly the page involved, if
we do not cross such a boundary.  The test is that all of the
following conditions pass:

	1) nbytes is <= walk->len_this_page

	   When scatterwalk_start() is invoked, walk->len_this_page
	   is set to the minimum of the remaining scatterlist segment
	   length and the remaining bytes in that page itself.

	2) walk->data + nbytes does not straddle a PAGE_CACHE_SIZE
	   boundary

This looks all fine to me.
