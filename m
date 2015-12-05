From: Philipp Matthias Hahn <pmhahn@pmhahn.de>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Sat, 5 Dec 2015 15:19:06 +0100
Message-ID: <20151205141906.GB31897@pmhahn.de>
References: <1447933294.1974772.444210441.67F1AC5E@webmail.messagingengine.com>
 <564DB5F5.9060208@profihost.ag>
 <1447936902.1986892.444251921.3928A049@webmail.messagingengine.com>
 <564DC4A5.70104@profihost.ag>
 <564DCC4C.1090009@redhat.com>
 <564E2852.8000200@profihost.ag>
 <56530A42.6030609@profihost.ag>
 <1448283451.4019628.447573353.3659E447@webmail.messagingengine.com>
 <565EBDC1.1090808@profihost.ag>
 <8737vlt6xb.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	Florian Weimer <fweimer@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8737vlt6xb.fsf@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Hannes,

On Wed, Dec 02, 2015 at 12:40:32PM +0100, Hannes Frederic Sowa wrote:
> > git bisect tells me it stopped working after those two commits were applied:
> >
> > commit d48623677191e0f035d7afd344f92cf880b01f8e
> > Author: Herbert Xu <herbert@gondor.apana.org.au>
> > Date:   Tue Sep 22 11:38:56 2015 +0800
> >
> >     netlink: Replace rhash_portid with bound
> >
> > commit 4e27762417669cb459971635be550eb7b5598286
> > Author: Herbert Xu <herbert@gondor.apana.org.au>
> > Date:   Fri Sep 18 19:16:50 2015 +0800
> >
> >     netlink: Fix autobind race condition that leads to zero port ID
> 
> Cool, thanks a lot. Does this patch make a difference?
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 59651af..278e94c 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1137,7 +1137,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
>  
>  	/* We need to ensure that the socket is hashed and visible. */
>  	smp_wmb();
> -	nlk_sk(sk)->bound = portid;
> +	nlk_sk(sk)->bound = true;
>  
>  err:
>  	release_sock(sk);

Didn't help, test program still gets stuck; sorry :-(

Philipp

-- 
  / /  (_)__  __ ____  __ Philipp Hahn
 / /__/ / _ \/ // /\ \/ /
/____/_/_//_/\_,_/ /_/\_\ pmhahn@pmhahn.de
