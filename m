From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH net-next 1/4] IPv6: HW csum support for outgoing large UFO packets
Date: Mon, 8 Jun 2009 09:36:55 +0300
Message-ID: <200906080936.55820.remi.denis-courmont@nokia.com>
References: <1244247387.1526.170.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"herbert.xu@redhat.com" <herbert.xu@redhat.com>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>
To: ext Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:37596 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbZFHGgY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 02:36:24 -0400
In-Reply-To: <1244247387.1526.170.camel@w-sridhar.beaverton.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 06 June 2009 03:16:27 ext Sridhar Samudrala wrote:
> @@ -668,7 +709,14 @@ static int udp_v6_push_pending_frames(struct soc=
k *sk)
>
>  	if (is_udplite)
>  		csum =3D udplite_csum_outgoing(sk, skb);
> -	 else
> +	 else if (sk->sk_no_check =3D=3D UDP_CSUM_NOXMIT) {	/* UDP csum dis=
abled */
> +		skb->ip_summed =3D CHECKSUM_NONE;
> +		goto send;

There is no such thing as disabled UDP in IPv6 (in *current* specs).

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

