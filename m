From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] netem: add cell concept to simulate
 special MAC behavior
Date: Tue, 29 Nov 2011 00:48:45 +0100
Message-ID: <1322524125.2970.48.camel@edumazet-laptop>
References: <1322156378-23257-1-git-send-email-hagen@jauu.net>
	 <1322187773-27768-1-git-send-email-hagen@jauu.net>
	 <1322187773-27768-2-git-send-email-hagen@jauu.net>
	 <1322521267.2970.43.camel@edumazet-laptop>
	 <20111128233004.GH3045@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:48809 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494Ab1K1Xst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 18:48:49 -0500
Received: by eaak14 with SMTP id k14so2378925eaa.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 15:48:48 -0800 (PST)
In-Reply-To: <20111128233004.GH3045@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 novembre 2011 =C3=A0 00:30 +0100, Hagen Paul Pfeifer a =C3=A9=
crit :
> * Eric Dumazet | 2011-11-29 00:01:07 [+0100]:
>=20
> >> -static psched_time_t packet_len_2_sched_time(unsigned int len, u3=
2 rate)
> >> +static psched_time_t packet_len_2_sched_time(unsigned int len,
> >> +					     struct netem_sched_data *q)
> >>  {
> >> -	return PSCHED_NS2TICKS((u64)len * NSEC_PER_SEC / rate);
> >> +	len +=3D q->packet_overhead;
> >> +
> >> +	if (q->cell_size) {
> >> +		u32 carry =3D len % q->cell_size;
> >> +		len +=3D carry;
> >
> >I dont understand this part  (len +=3D carry;)
>=20
> Say the original packet is 100 byte, cellsize is 40 byte: three full =
size link
> layer frames are required: 40 + 40 + 40 =3D=3D 100 + 20. This is used=
 for TDMA,
> ATM or slot schemes where the remainder cannot be used.
>=20

I still dont understand.

Say you send 119 bytes

119 % 40 =3D 39

119 + 39 =3D 158

Is it was is really needed ?

> Later in code carry is reused if cell overhead is configured.
>=20

In this example, cells will be :

158 / 40 =3D 3   + one (because carry is not 0)

len +=3D 4 * cell_overhead
