From: John Heffner <jheffner@psc.edu>
Subject: Re: TCP's initial cwnd setting correct?...
Date: Wed, 08 Aug 2007 11:20:05 -0400
Message-ID: <46B9DF25.3000800@psc.edu>
References: <Pine.LNX.4.64.0708061508070.8788@kivilampi-30.cs.helsinki.fi> <20070807.182823.123919803.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:64075 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368AbXHHPuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 11:50:09 -0400
In-Reply-To: <20070807.182823.123919803.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I believe the current calculation is correct.  The RFC specifies a=20
window of no more than 4380 bytes unless 2*MSS > 4380.  If you change=20
the code in this way, then MSS=3D1461 will give you an initial window o=
f=20
3*MSS =3D=3D 4383, violating the spec.  Reading the pseudocode in the R=
=46C=20
3390 is a bit misleading because they use a clamp at 4380 bytes rather=20
than use a multiplier in the relevant range.

   -John


David Miller wrote:
> From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 6 Aug 2007 15:37:15 +0300 (EEST)
>=20
>> @@ -805,13 +805,13 @@ void tcp_update_metrics(struct sock *sk)
>>  	}
>>  }
>> =20
>> -/* Numbers are taken from RFC2414.  */
>> +/* Numbers are taken from RFC3390.  */
>>  __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst)
>>  {
>>  	__u32 cwnd =3D (dst ? dst_metric(dst, RTAX_INITCWND) : 0);
>> =20
>>  	if (!cwnd) {
>> -		if (tp->mss_cache > 1460)
>> +		if (tp->mss_cache >=3D 2190)
>>  			cwnd =3D 2;
>>  		else
>>  			cwnd =3D (tp->mss_cache > 1095) ? 3 : 4;
>=20
> I remember suggesting something similar about 5 or 6 years
> ago and Alexey Kuznetsov at the time explained the numbers
> which are there and why they should not be changed.
>=20
> I forget the reasons though, and I'll try to do the research.
>=20
> These numbers have been like this forever, FWIW.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

