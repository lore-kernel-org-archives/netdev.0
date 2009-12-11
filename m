From: Frederic Leroy <fredo@starox.org>
Subject: Re: TCP not retransmitting
Date: Fri, 11 Dec 2009 13:57:34 +0100
Message-ID: <20091211125734.GA23559@sd-11162.dedibox.fr>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de> <4B1C9D94.3070504@gmail.com> <4B1CE45A.9010908@tvk.rwth-aachen.de> <4B1D27F7.9000502@tvk.rwth-aachen.de> <alpine.DEB.2.00.0912072046500.27565@melkinpaasi.cs.helsinki.fi> <20091207200904.5f6e145a@houba> <alpine.DEB.2.00.0912101518050.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:39386 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbZLKM52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 07:57:28 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912101518050.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ilpo,

On Thu, Dec 10, 2009 at 03:24:20PM +0200, Ilpo J=E4rvinen wrote:
> Hi,
>=20
> Now that the more important issues are out of the way, could try with=
 the=20
> following debug patch, if we could get some information on why the=20
> retransmission are not happening when they're supposed to (the EAGAIN=
=20
> problem we noticed earlier). Besides trying with 2.6.32, it might als=
o be=20
> worth of the effort to try that in 2.6.31 to see if that also gives t=
hose=20
> EAGAIN things or if it's a new issue. It is quite insignificant wheth=
er=20
> to previous fix patch is included or not though perhaps easier to kno=
w=20
> that the problem really happened if a stall is experiencable vs. the =
fixed=20
> kernel.

I made 3 test this time. Unlike the other, I put them appart in a new d=
irectory :=20
http://www.starox.org/pub/scp_stall/eagain/

The first was made with 2.6.31 kernel.
I disconnected the ethernet cable for about 30s.
There was some eagain error.

The two other were made with 2.6.32, without the fix.
I didn't disconnected anything as I know it will fails quickly :)
The first try has an eagain error.

>=20
> --=20
>  i.
>=20
>=20
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index fcd278a..c29aed0 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1894,6 +1894,8 @@ int tcp_retransmit_skb(struct sock *sk, struct =
sk_buff *skb)
>  		icsk->icsk_mtup.probe_size =3D 0;
>  	}
> =20
> +	printk("sk: %p wm_a: %u wm_q: %u sbuf: %u\n", sk,
> +		atomic_read(&sk->sk_wmem_alloc), sk->sk_wmem_queued, sk->sk_sndbuf=
);
>  	/* Do not sent more than we queued. 1/4 is reserved for possible
>  	 * copying overhead: fragmentation, tunneling, mangling etc.
>  	 */
> @@ -1986,6 +1988,7 @@ int tcp_retransmit_skb(struct sock *sk, struct =
sk_buff *skb)
>  		 */
>  		TCP_SKB_CB(skb)->ack_seq =3D tp->snd_nxt;
>  	}
> +	printk("sk: %p E %u", sk, err);
                           ^
                      missing \n ;-)
>  	return err;
>  }

--=20
=46r=E9d=E9ric Leroy
