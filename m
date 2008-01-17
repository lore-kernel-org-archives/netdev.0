From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 14:37:26 +0200
Message-ID: <478F4C06.4040704@iki.fi>
References: <478F276D.8080407@iki.fi>	<20080117.020616.136852595.davem@davemloft.net>	<478F3539.5060903@iki.fi> <20080117.030827.72477184.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:43171 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbYAQMgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 07:36:12 -0500
Received: by fg-out-1718.google.com with SMTP id e21so658967fga.17
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 04:36:11 -0800 (PST)
In-Reply-To: <20080117.030827.72477184.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Timo_Ter=E4s <timo.teras@iki.fi>
> Date: Thu, 17 Jan 2008 13:00:09 +0200
>=20
>> IMHO, it's a lot better then losing >50% of entries and the end
>> of sequence message on big dumps. SPD and SADB are not that
>> volatile; in most of the cases the dump would be as good as an
>> atomic one.
>=20
> I humbly disagree with you.  Interface behavior stability
> is more important.

Small SPDs/SADBs would still be dumped atomically. The patch
affects only the cases when the receive queue is getting full.

>> I'm not sure if there's other major applications that we should
>> be concerned about, but at least ipsec-tools racoon does not
>> expect to get atomic dumps (which btw, comes originally from BSD).
>=20
> Racoon was written as an addon to the BSD stack by an IPV6/IPSEC
> project in Japan named KAME, it did not "come from BSD".  It was
> added to BSD.
>=20
> There are also other BSD based IPSEC daemons such as the one written
> by the OpenBSD folks.

Yes. I meant that it was originally written to be used in BSD. The
Linux port came later. Sorry for the ambiguous wording.

> I don't think this is arguable at all.  We're not changing semantics
> over what we've done for 4+ years and applications might depend upon.
> It's for a deprecated interface, which makes any semantic changes tha=
t
> much less inviting.
>=20
> You can argue all you want, but it will not change the invariants in
> the previous paragraph.

True. If no one else agrees with me, I'll drop it. I can always run
my own patched kernel.

I'd appreciate feedback on the xfrm changes. I'll try to make that
part usable patch against net-2.6.25 git tree next week.
