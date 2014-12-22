From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH net-next] tun: support retrieving multiple packets in
 a single read with IFF_MULTI_READ
Date: Mon, 22 Dec 2014 23:09:57 +1100
Message-ID: <20141222120957.GA21319@gondor.apana.org.au>
References: <1417752000-27171-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasonwang@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	herbert@gondor.apena.org.au, kernel-team@fb.com, agartrell@fb.com
To: Alex Gartrell <agartrell@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417752000-27171-1-git-send-email-agartrell@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alex Gartrell <agartrell@fb.com> wrote:
> This patch adds the IFF_MULTI_READ flag.  This has the following behavior.
> 
> 1) If a read is too short for a packet, a single stripped packet will be read
> 
> 2) If a read is long enough for multiple packets, as many *full* packets
> will be read as possible.  We will not return a stripped packet, so even if
> there are many, many packets, we may get a short read.
> 
> In casual performance testing with a simple test program that simply reads
> and counts packets, IFF_MULTI_READ conservatively yielded a 30% CPU win, as
> measured by top.  Load was being driven by a bunch of hpings running on a
> server on the same L2 network (single hop through a top-of-rack switch).
> 
> Signed-off-by: Alex Gartrell <agartrell@fb.com>

As tun already has a socket interface can we do this through
recvmmsg?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
