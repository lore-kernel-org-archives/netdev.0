From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_net: indicate oom when addbuf returns failure
Date: Mon, 7 Jun 2010 12:15:18 +0300
Message-ID: <20100607091518.GB5561@redhat.com>
References: <201006041028.56798.rusty@rustcorp.com.au>
	<20100606201258.GA21196@redhat.com>
	<20100606222441.GA5992@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Bruce Rogers <brogers@novell.com>, netdev@vger.kernel.org,
        Shirley Ma <mashirle@us.ibm.com>,
        virtualization@lists.linux-foundation.org, stable@kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20100606222441.GA5992@gondor.apana.org.au>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 07, 2010 at 08:24:41AM +1000, Herbert Xu wrote:
> On Sun, Jun 06, 2010 at 11:13:00PM +0300, Michael S. Tsirkin wrote:
> >
> > Actually this code looks strange:
> > Note that add_buf inicates out of memory
> > condition with a positive return value, and ring full
> > (which is not an error!) with -ENOSPC.
> 
> Indeed, this ultimately came from
> 
> commit 9ab86bbcf8be755256f0a5e994e0b38af6b4d399
> Author: Shirley Ma <mashirle@us.ibm.com>
> Date:   Fri Jan 29 03:20:04 2010 +0000
> 
>     virtio_net: Defer skb allocation in receive path Date: Wed, 13 Jan 2010 12:53:38 -0800
> 
> (Greg, please don't apply this even though I've just given you
> the upstream commit ID that you were asking for :)
> 
> where it confuses a memory allocation error with an add_buf failure.
> 
> > Possibly the right thing to do is to
> > 1. handle ENOMEM specially
> > 2. fix add_buf to return ENOMEM on error
> 
> I think we should make it so that only a memory allocation error
> is returned as before.  There is no need for returning the add_buf
> error unless add_buf is now doing an allocation itself that needs
> to be retried.

That's what my patch did, right? Ack it?

> Thanks,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
