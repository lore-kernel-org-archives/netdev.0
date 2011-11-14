From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: reduce skb truesize by 50%
Date: Mon, 14 Nov 2011 16:57:45 +0100
Message-ID: <1321286265.2272.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1321213338.17837.38.camel@edumazet-laptop>
	 <1321214895.3101.3.camel@lb-tlvb-eilong.il.broadcom.com>
	 <1321221657.17837.51.camel@edumazet-laptop>
	 <20111114.000811.780218767629149648.davem@davemloft.net>
	 <1321251945.17837.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eilong@broadcom.com, bhutchings@solarflare.com,
	pstaszewski@itcare.pl, netdev@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>,
	Tom Herbert <therbert@google.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50515 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651Ab1KNP5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 10:57:51 -0500
Received: by fagn18 with SMTP id n18so3142178fag.19
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 07:57:50 -0800 (PST)
In-Reply-To: <1321251945.17837.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 novembre 2011 =C3=A0 07:25 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le lundi 14 novembre 2011 =C3=A0 00:08 -0500, David Miller a =C3=A9cr=
it :
>=20
> > I fully support bringing this thing back to life :-)
>=20
> I'll make extensive tests today and provide two patches when ready, w=
ith
> all performance results.
>=20
> Some prefetch() calls will be removed, since build_skb() provides
> already cache hot skb.

Impressive results :

before : 720.000 pps
after :  820.000 pps

[ One mono threaded application receiving UDP messages on a single
socket, asking IP_PKTINFO ancillary info ]

Latencies are also a bit improved : softirq handler dirties about 320
bytes less per skb.

Definitely worth the pain.

I am sending two patches. Other drivers probably can benefit from
build_skb() as well.

[PATCH net-next 1/2] net: introduce build_skb()
[PATCH net-next 2/2] bnx2x: uses build_skb() in receive path
