From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Mon, 7 Dec 2015 09:20:42 +0800
Message-ID: <20151207012042.GA7420@gondor.apana.org.au>
References: <564DC4A5.70104@profihost.ag>
 <564DCC4C.1090009@redhat.com>
 <564E2852.8000200@profihost.ag>
 <56530A42.6030609@profihost.ag>
 <1448283451.4019628.447573353.3659E447@webmail.messagingengine.com>
 <565EBDC1.1090808@profihost.ag>
 <8737vlt6xb.fsf@stressinduktion.org>
 <5661DAC4.8040909@profihost.ag>
 <20151205010819.GA21889@gondor.apana.org.au>
 <5664A102.2030602@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Weimer <fweimer@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	jannik Winkel <j.winkel@profihost.ag>,
	Marco Schinkel <m.schinkel@profihost.ag>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org
To: Stefan Priebe <s.priebe@profihost.ag>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5664A102.2030602@profihost.ag>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 06, 2015 at 09:56:34PM +0100, Stefan Priebe wrote:
> Hi Herbert,
> 
> i think i found the issue in 4.1 with netlink. Somebody made a
> mistake while backporting or cherry-picking your patch "netlink: Fix
> autobind race condition that leads to zero port ID" to 4.1.
> 
> It misses a goto in 4.1.
> 
> This goto is missing in 4.1:
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 4017e12..f15c001 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1132,7 +1132,6 @@ static int netlink_insert(struct sock *sk, u32 portid)
>                 if (err == -EEXIST)
>                         err = -EADDRINUSE;
>                 sock_put(sk);
> -               goto err;
>         }
> 
>         /* We need to ensure that the socket is hashed and visible. */
> 
> Can you please confirm, that this is not correct and might cause
> those issues.

Well spotted! Yes this would be a fatal error and can cause the
problems you guys are seeing.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
