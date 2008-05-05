From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC/T] [NET] make pskb_expand_head warn when called with
	invalid state
Date: Mon, 05 May 2008 17:40:47 +0200
Message-ID: <1210002047.8245.31.camel@johannes.berg>
References: <1209924962.3655.8.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-cir08moTdJkCKYmGL86z"
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:54039 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbYEEPlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 11:41:39 -0400
In-Reply-To: <1209924962.3655.8.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cir08moTdJkCKYmGL86z
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-05-04 at 20:16 +0200, Johannes Berg wrote:
> This makes pskb_expand_head warn when called when a socket is attached.
=20
> +	WARN_ON((nhead || ntail) && skb->sk);
> +

This is triggering now. I think it's a false positive, trace below.

[23194.608011] Badness at net/core/skbuff.c:726
[23194.608014] NIP: c02735c8 LR: c02735a0 CTR: 00000000
[23194.608017] REGS: ccf9baf0 TRAP: 0700   Not tainted  (2.6.25-wl-06933-g0=
bacadf-dirty)
[23194.608020] MSR: 00029032 <EE,ME,IR,DR>  CR: 48242448  XER: 20000000
[23194.608028] TASK =3D e6430e20[15208] 'distcc' THREAD: ccf9a000
[23194.608031] GPR00: 00000001 ccf9bba0 e6430e20 fffffff4 cccccccc 00000004=
 c1497120 c1497148=20
[23194.608040] GPR08: 0000005a 00000000 0000005a c08bc200 28242442 1002d36c=
 ccf9bd18 ccf9bd28=20
[23194.608049] GPR16: 000005a8 00000001 00000000 ccf6860c 00000000 00000000=
 00000000 00000000=20
[23194.608057] GPR24: 00000000 00000000 000005a8 00000720 00000628 00000000=
 c1496120 d0e67110=20
[23194.608067] NIP [c02735c8] pskb_expand_head+0x80/0x1f8
[23194.608071] LR [c02735a0] pskb_expand_head+0x58/0x1f8
[23194.608074] Call Trace:
[23194.608077] [ccf9bba0] [c02735a0] pskb_expand_head+0x58/0x1f8 (unreliabl=
e)
[23194.608082] [ccf9bbc0] [c02737a4] __pskb_pull_tail+0x64/0x374
[23194.608087] [ccf9bbf0] [c027b94c] dev_queue_xmit+0x1e4/0x3cc
[23194.608093] [ccf9bc10] [c02a5c54] ip_finish_output+0x1e8/0x354
[23194.608098] [ccf9bc30] [c02a61b0] ip_local_out+0x34/0x48
[23194.608104] [ccf9bc40] [c02a699c] ip_queue_xmit+0x1fc/0x38c
[23194.608109] [ccf9bcc0] [c02b94d4] tcp_transmit_skb+0x454/0x878
[23194.608115] [ccf9bcf0] [c02bbfb4] tcp_push_one+0x124/0x1f0
[23194.608120] [ccf9bd10] [c02b014c] tcp_sendpage+0x6ec/0x6f4
[23194.608125] [ccf9bd80] [c0269ec0] sock_sendpage+0x34/0x44
[23194.608130] [ccf9bd90] [c00c6dc8] pipe_to_sendpage+0x84/0xa4
[23194.608136] [ccf9bdc0] [c00c802c] __splice_from_pipe+0x118/0x290
[23194.608142] [ccf9be00] [c00c8328] splice_from_pipe+0x64/0x8c
[23194.608147] [ccf9be40] [c00c72d4] do_splice_from+0x80/0x9c
[23194.608152] [ccf9be60] [c00c7aac] splice_direct_to_actor+0xb8/0x1e0
[23194.608158] [ccf9bea0] [c00c7c18] do_splice_direct+0x44/0x80
[23194.608163] [ccf9bed0] [c00a0494] do_sendfile+0x1ec/0x2b0
[23194.608169] [ccf9bf10] [c00a0740] sys_sendfile+0xb4/0x108
[23194.608174] [ccf9bf40] [c00124cc] ret_from_syscall+0x0/0x38


--=-cir08moTdJkCKYmGL86z
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB8qfqVg1VMiehFYAQLlbw/9H1uxL8uVjL16V6we3hYjQl7RDYN6Dzqd
zV1GCrB2sih6h3fxYu2b03odlVpSopYm4yHTf0N7tIwPWsgIabwWttRcA0dBvLy/
JZLICDAKNjnd5RXE3zrF5GihRUi+gpeRSMRFhv40hZEpRbj1R+gV1K0CzXFoLuXz
9map01CCSFufVOhguDioCI+oLC7sHSw2EM+WcUmtYuIFG+fzN5ov6c+3Krfpx0zV
2LVlwKdLfQBthCgObAv0wa8S3POBawt3ct1fWWwILCW2MKRkGoE+OFFS4NgdFOw/
7aC7ZmvVvinpWYA1YrAAp7N2U/N5XtL4bJ+miJny6HUAGNhpAm4BItJFTYQiz1J9
cDxgYUr3FaYTxY8QEONdP/EuZmBj6ZJDjlMsd/nIhEE2qCEDCQIF/nCDvl3DQQVB
26cYDkcHSPB/uXUs14e4cKAwWW274Oeq7VIV/h1JTI1jFp+qA8a3Ukvf3BwzlVIS
RoyCMZNSgYZBlSrn2lKskwENXgBkTjYZCeL79rzqHVb5y0DrlpPvf8OqAd0hbAm+
ylcqbcxpa5oXM4fz86j/DQBbn+84DNY4R3ajhqkwghxKXEOKhj7DzAV7XAblYNO0
V+vXqSD8GLXpFyqSJ5XmH0xTs6a2bKgOFDeb2+G3nv2vK9dbxyfsl4fvcZHmVlC5
hMMXW4Ajl00=
=u7Bw
-----END PGP SIGNATURE-----

--=-cir08moTdJkCKYmGL86z--

