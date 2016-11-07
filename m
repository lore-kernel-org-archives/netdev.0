From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next] qed: Prevent stack corruption on MFW interaction
Date: Mon, 7 Nov 2016 12:25:42 +0000
Message-ID: <BL2PR07MB23060C5BFFA4738BE48D644F8DA70@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1478445147-23163-1-git-send-email-Yuval.Mintz@cavium.com>
 <063D6719AE5E284EB5DD2968C1650D6DB021652B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: David Laight <David.Laight@ACULAB.COM>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0056.outbound.protection.outlook.com ([104.47.42.56]:3236
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753047AbcKGMZp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Nov 2016 07:25:45 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB021652B@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Driver uses a union for copying data to & from management firmware
> > when interacting with it.
> > Problem is that the function always copies sizeof(union) while commit
> > 2edbff8dcb5d ("qed: Learn resources from management firmware") is
> > casting a union elements which is of smaller size [24-byte instead of 8=
8-bytes].
> >
> > Also, the union contains some inappropriate elements which increase
> > its size [should have been 32-bytes]. While this shouldn't corrupt
> > other PF messages to the MFW [as management firmware enforces
> > permissions so that each PF is allowed to write only to its own
> > mailbox] we fix this here as well.
> ...
>=20
> Is it worth adding a compile-time assert on the size of the union?
>=20
> 	David

I don't think so; The MFW team defines the elements and already enforces th=
at.

It was simply a slip in my initial submission, where I omitted some
stuff that was already part of their HSI and wasn't required for that
submission, and missed the fact it was a union and not a struct
[hence uniting the removed fields to retain 'correct offsets' of fields].
