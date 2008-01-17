From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 13:00:09 +0200
Message-ID: <478F3539.5060903@iki.fi>
References: <478F2205.80403@iki.fi>	<20080117.014458.16733544.davem@davemloft.net>	<478F276D.8080407@iki.fi> <20080117.020616.136852595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:49525 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbYAQK7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 05:59:05 -0500
Received: by fg-out-1718.google.com with SMTP id e21so633401fga.17
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 02:59:02 -0800 (PST)
In-Reply-To: <20080117.020616.136852595.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Timo_Ter=E4s <timo.teras@iki.fi>
> Date: Thu, 17 Jan 2008 12:01:17 +0200
>=20
>> David Miller wrote:
>>> This is an inherent aspect of AF_KEY (and what it was
>>> derived from, BSD routing sockets).
>> Yes, this is the way BSD does it.
>> =20
>>> It has to provide dumps atomically, and if there is no
>>> space there is no way to provide those entries which
>>> would require more rcvbuf space.
>> RFC does not say it has to be atomic.
>=20
> Every application out there in the universe expects BSD socket
> semantics, and therefore atomic dumps.  You cannot "fix" things
> without breaking applications.

IMHO, it's a lot better then losing >50% of entries and the end
of sequence message on big dumps. SPD and SADB are not that
volatile; in most of the cases the dump would be as good as an
atomic one.

Even if it did change during ongoing dump you still get an usable
dump. All the entries reflect real data and there is no dependency
between different entries.

I'm not sure if there's other major applications that we should
be concerned about, but at least ipsec-tools racoon does not
expect to get atomic dumps (which btw, comes originally from BSD).

Cheers,
  Timo

