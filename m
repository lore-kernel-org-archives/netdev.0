From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 07:54:32 +0200
Message-ID: <478EED98.6080603@iki.fi>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au> <1200533980.4451.100.camel@localhost> <20080117021743.GA5182@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:45120 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbYAQFxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 00:53:19 -0500
Received: by fg-out-1718.google.com with SMTP id e21so548461fga.17
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 21:53:18 -0800 (PST)
In-Reply-To: <20080117021743.GA5182@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Wed, 2008-16-01 at 16:28 +0200, Timo Ter=E4s wrote:
>> > No. I'm not creating second copies of the SADB/SPD entries. The en=
tries
>> > are just added to one more list.
>=20
> Ah, sorry - yes, that sounds reasonable.
> So what happens if i delete an entry; does it get removed from the li=
st?
> Also what happens on modification?

If the entry is removed befored it is dumped, it wont be dumped at all.
The state during dump code execution is returned. Depending when the
modification occurs it might or might not be reflected in the dumped
entry.

>> > If more entries are added, you can get notifications of them.
>=20
> how would a user app (example racoon) appropriately deal with it?
> Example an entry sits in the dump-list, it gets deleted - an event ge=
ts
> generated user-space and later that entry shows up in user space dump=
=2E

You listen for the events. It is guaranteed that if the dumping code
does return the entry to be deleted, the deletion notification will
occur after that dump entry.

Herbert Xu wrote:
> On Wed, Jan 16, 2008 at 08:39:40PM -0500, jamal wrote:
>> I wouldnt disagree except some apps like racoon which depend on pfke=
y
>> are unfortunately beyond repair. Timo has a pretty good handle on th=
e
>=20
> Racoon doesn't use pfkey dumping as far as I know.

ipsec-tools racoon uses pfkey and only pfkey. And it's non trivial to
make it use netlink; it relies heavily all around the code to pfkey
structs. It also runs on BSD so we cannot rip pfkey away; adding a
layer to work with both pfkey and netlink would be doable, but just a
lot of work.

Also ipsec-tools racoon seems to be the default IKE daemon in some
popular distros. So for the time being I think pfkey is an evil we have
to live with.

Cheers,
  Timo
