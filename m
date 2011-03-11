From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Re: [PATCH 3/6] tcp_cubic: fix comparison of jiffies
Date: Fri, 11 Mar 2011 10:40:22 +0100
Message-ID: <20110311094022.GA15941@xanadu.blop.info>
References: <20110310165119.224046957@vyatta.com>
 <20110310165328.999266946@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, sangtae.ha@gmail.com, rhee@ncsu.edu,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:32991 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838Ab1CKJvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 04:51:33 -0500
Content-Disposition: inline
In-Reply-To: <20110310165328.999266946@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/11 at 08:51 -0800, Stephen Hemminger wrote:
> --- a/net/ipv4/tcp_cubic.c	2011-03-10 08:08:32.867492953 -0800
> +++ b/net/ipv4/tcp_cubic.c	2011-03-10 08:24:39.658201745 -0800
> @@ -342,9 +342,11 @@ static void hystart_update(struct sock *
>  		u32 curr_jiffies =3D jiffies;
> =20
>  		/* first detection parameter - ack-train detection */
> -		if (curr_jiffies - ca->last_jiffies <=3D msecs_to_jiffies(2)) {
> +		if ((s32)(curr_jiffies - ca->last_jiffies) <=3D
> +		    msecs_to_jiffies(2)) {
>  			ca->last_jiffies =3D curr_jiffies;
> -			if (curr_jiffies - ca->round_start >=3D ca->delay_min>>4)
> +			if ((s32) (curr_jiffies - ca->round_start) <=3D
> +			    ca->delay_min >> 4)

>=3D, not <=3D
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
