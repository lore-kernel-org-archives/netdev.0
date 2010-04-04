From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sun, 04 Apr 2010 14:06:55 +0300
Message-ID: <4BB872CF.2030202@iki.fi>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100404104230.GA10368@gondor.apana.org.au> <4BB86EE8.5090203@iki.fi> <20100404110014.GA10864@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:35265 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752815Ab0DDLG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 07:06:58 -0400
Received: by ewy20 with SMTP id 20so867993ewy.1
        for <netdev@vger.kernel.org>; Sun, 04 Apr 2010 04:06:57 -0700 (PDT)
In-Reply-To: <20100404110014.GA10864@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sun, Apr 04, 2010 at 01:50:16PM +0300, Timo Ter=E4s wrote:
>> Because flow_cache_entry is per-cpu, and multiple entries (due to
>> different flows matching same policies, or same flow having multiple
>> per-cpu entries) can point to same policy. If we cached "dummy" obje=
cts
>> for even policies, then this would be better approach.
>=20
> Oh yes of course.
>=20
> But what we could do is embed most of flow_cache_entry into
> xfrm_policy (and xdst in your latter patches) along with the
> ops pointer.
>=20
> Like this:
>=20
> struct flow_cache_object {
> 	u16			family;
> 	u8			dir;
> 	u32			genid;
> 	struct flowi		key;
> 	struct flow_cache_ops **ops;
> };
>=20
> struct flow_cache_entry {
> 	struct flow_cache_entry	*next;
> 	struct flow_cache_object *obj;
> };
>=20
> struct xfrm_policy {
> 	struct flow_cache_object flo;
> 	...
> };
>=20
> What do you think?

It would still not work for policies. For every policy X we
can get N+1 different matches with separate struct flowi contents.
It's not possible to put single struct flowi or any other of
the flow details in to xfrm_policy. It's a N-to-1 mapping. Not
a 1-to-1 mapping.

