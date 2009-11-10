From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible bug: SO_TIMESTAMPING 2.6.30+
Date: Tue, 10 Nov 2009 09:44:20 +0100
Message-ID: <4AF927E4.7040306@gmail.com>
References: <4AF8B67E.3030604@ripnet.com> <20091110091252.1667d27d@pundit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Marcus D. Leech" <mleech@ripnet.com>, netdev@vger.kernel.org
To: Christopher Zimmermann <madroach@zakweb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50425 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbZKJIoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 03:44:17 -0500
In-Reply-To: <20091110091252.1667d27d@pundit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christopher Zimmermann a =E9crit :
> On Mon, 09 Nov 2009 19:40:30 -0500
> "Marcus D. Leech" <mleech@ripnet.com> wrote:
>=20
>=20
>> I know that Patrick Ohly has essentially moved on from doing the=20
>> SO_TIMESTAMPING stuff, so
>>    who's maintaining it now?
>=20
> I worked on it a month ago or so and have a patchset from Patick Ohly
> and some changes by me which fix software timestamping and make the
> ioctl interface to the hardware more flexible (keeping backwards
> compatibility). Patches are attached.
> Still I never tried IPv6 and don't think the patches do anything abou=
t
> it.
> It would be nice to know weather software tx timestamps work
> with/without the patches.
>=20
>=20
> Christopher
>=20

I see some sock_put()/sock_hold() stuff in your second patch.

We removed these things on transmit path, please dont add them back...

If skb->sk is set, it probably also has a destructor and a reference al=
ready taken.

(This reference being on sk_wmem_alloc by the way, not on sk_refcnt)

You probably can try to change skb destructor ?


