From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 12:01:17 +0200
Message-ID: <478F276D.8080407@iki.fi>
References: <478F1DEA.5070903@iki.fi>	<20080117.013107.241902256.davem@davemloft.net>	<478F2205.80403@iki.fi> <20080117.014458.16733544.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:2909 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588AbYAQKAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 05:00:05 -0500
Received: by fg-out-1718.google.com with SMTP id e21so616034fga.17
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 02:00:03 -0800 (PST)
In-Reply-To: <20080117.014458.16733544.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Timo_Ter=E4s <timo.teras@iki.fi>
> Date: Thu, 17 Jan 2008 11:38:13 +0200
>=20
>> The af_key issue is that in big dumps you get only first X
>> entries. The rest of the entries are dropped because the
>> socket receive buffer goes full. You get data corruption:
>> missing entries.
>=20
> This is an inherent aspect of AF_KEY (and what it was
> derived from, BSD routing sockets).

Yes, this is the way BSD does it.
=20
> It has to provide dumps atomically, and if there is no
> space there is no way to provide those entries which
> would require more rcvbuf space.

RFC does not say it has to be atomic.

It does say that the dump is terminated with SADB_DUMP
message having sadb_seq field set to zero. Currently
that is dropped too when the problem occurs. Thus the
socket is left in a bad state: dump ends never. This
can cause applications without any workarounds to hang.

- Timo
=20
