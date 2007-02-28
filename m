From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH 1/2] [TCP]: Add two new spurious RTO responses to FRTO
Date: Wed, 28 Feb 2007 13:13:02 +0100
Message-ID: <20070228121302.GA2983@ff.dom.local>
References: <Pine.LNX.4.64.0702271738340.19465@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?us-ascii?B?PT9JU08tODg1OS0yP1E/SWxwb19KPUU0cnZpbmVuPz0=?=
	<ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:35076 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932159AbXB1MJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 07:09:19 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702271738340.19465@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27-02-2007 16:50, Ilpo J=E4rvinen wrote:
> New sysctl tcp_frto_response is added to select amongst these
=2E..
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> @@ -762,15 +763,17 @@ __u32 tcp_init_cwnd(struct tcp_sock *tp,
>  }
> =20
>  /* Set slow start threshold and cwnd not falling to slow start */
> -void tcp_enter_cwr(struct sock *sk)
> +void tcp_enter_cwr(struct sock *sk, const int set_ssthresh)
>  {
>  	struct tcp_sock *tp =3D tcp_sk(sk);
> +	const struct inet_connection_sock *icsk =3D inet_csk(sk);
> =20
>  	tp->prior_ssthresh =3D 0;
>  	tp->bytes_acked =3D 0;
>  	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {

-	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {
+	if (icsk->icsk_ca_state < TCP_CA_CWR) {

Probably something for the next "BTW".

Regards,
Jarek P.

>  		tp->undo_marker =3D 0;
> -		tp->snd_ssthresh =3D inet_csk(sk)->icsk_ca_ops->ssthresh(sk);
> +		if (set_ssthresh)
> +			tp->snd_ssthresh =3D icsk->icsk_ca_ops->ssthresh(sk);
=2E..
