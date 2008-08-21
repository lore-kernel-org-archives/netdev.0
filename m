From: Matt LaPlante <kernel1@cyberdogtech.com>
Subject: Re: Oops in authenc: 2.6.26.3
Date: Thu, 21 Aug 2008 08:08:11 -0500
Message-ID: <20080821080811.8a834a46.kernel1@cyberdogtech.com>
References: <20080820203245.ea01ff39.kernel1@cyberdogtech.com>
	<20080821070225.GA31894@aeris>
	<20080821083615.GA1971@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sascha Biberhofer <biberhofer@inode.at>,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757996AbYHUNIk@vger.kernel.org>
In-Reply-To: <20080821083615.GA1971@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Aug 2008 18:36:15 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Aug 21, 2008 at 07:02:25AM +0000, Sascha Biberhofer wrote:
> > I have the same problem on my system, starting with the release of
> > 2.6.26. Shortly afterwards I've had the same problem with the 2.6.25
> > series starting with 2.6.25.12. I've looked up the changes between
> > 2.6.25.11 and .12 and found commit
> > c2bd04d8040a91fe2ee2e9fee1a6562ca9792249 (it's commit
> > 872ac8743cb400192a9fce4ba2d3ffd7bb309685 in the 2.6.26 series).
> > Reverting the commit seems to solve the problem here, I've been running
> > a 2.6.25.12 kernel without this commit for some weeks now.
> > In case it's important: I'm using an IPSec ESP transport with AES-256
> > and sha-256 auth. 
> 
> Sorry, I was skimping on memory and ended up calling a clobbered
> function pointer.
> 
> This patch should fix it.
> 
> crypto: authenc - Avoid using clobbered request pointer
> 
> Authenc works in two stages for encryption, it first encrypts and
> then computes an ICV.  The context memory of the request is used
> by both operations.  The problem is that when an asynchronous
> encryption completes, we will compute the ICV and then reread the
> context memory of the encryption to get the original request.
> 
> It just happens that we have a buffer of 16 bytes in front of the
> request pointer, so ICVs of 16 bytes (such as SHA1) do not trigger
> the bug.  However, any attempt to uses a larger ICV instantly kills
> the machine when the first asynchronous encryption is completed.
> 
> This patch fixes this by saving the request pointer before we start
> the ICV computation.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Matt LaPlante <kernel1@cyberdogtech.com>

Thanks for the quick fix!

-- 
Matt LaPlante
