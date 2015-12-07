From: Philipp Hahn <pmhahn@pmhahn.de>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Mon, 7 Dec 2015 08:41:38 +0100
Message-ID: <56653832.2030607@pmhahn.de>
References: <564DB5F5.9060208@profihost.ag>
 <1447936902.1986892.444251921.3928A049@webmail.messagingengine.com>
 <564DC4A5.70104@profihost.ag> <564DCC4C.1090009@redhat.com>
 <564E2852.8000200@profihost.ag> <56530A42.6030609@profihost.ag>
 <1448283451.4019628.447573353.3659E447@webmail.messagingengine.com>
 <565EBDC1.1090808@profihost.ag> <8737vlt6xb.fsf@stressinduktion.org>
 <5661DAC4.8040909@profihost.ag> <20151205010819.GA21889@gondor.apana.org.au>
 <5664A102.2030602@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Weimer <fweimer@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	jannik Winkel <j.winkel@profihost.ag>,
	Marco Schinkel <m.schinkel@profihost.ag>
To: Stefan Priebe <s.priebe@profihost.ag>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5664A102.2030602@profihost.ag>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Stefan,

Am 06.12.2015 um 21:56 schrieb Stefan Priebe:
> i think i found the issue in 4.1 with netlink. Somebody made a mistake
> while backporting or cherry-picking your patch "netlink: Fix autobind
> race condition that leads to zero port ID" to 4.1.
> 
> It misses a goto in 4.1.
> 
> This goto is missing in 4.1:
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 4017e12..f15c001 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1132,7 +1132,6 @@ static int netlink_insert(struct sock *sk, u32
> portid)
>                 if (err == -EEXIST)
>                         err = -EADDRINUSE;
>                 sock_put(sk);
> -               goto err;
>         }
> 
>         /* We need to ensure that the socket is hashed and visible. */
> 
> Can you please confirm, that this is not correct and might cause those
> issues.

I just tested that patch and it seems to fix our hang. Thank you for
your good work.

Philipp

PS: I guess I can skip testing your other test request as this simple
patch is part of your other hiuq4bsW patch. If I should still test it,
just send a note.
