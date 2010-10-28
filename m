From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Thu, 28 Oct 2010 11:37:46 -0700 (PDT)
Message-ID: <20101028.113746.104048682.davem@davemloft.net>
References: <20101028.112231.232747062.davem@davemloft.net>
	<AANLkTinq5iYU3A41vLHLLWVpoS-A4mB-RYrrWYCGKk+-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, drosenberg@vsecurity.com,
	jon.maloy@ericsson.com, allan.stephens@windriver.com
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60360
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761328Ab0J1ShW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 14:37:22 -0400
In-Reply-To: <AANLkTinq5iYU3A41vLHLLWVpoS-A4mB-RYrrWYCGKk+-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 28 Oct 2010 11:33:56 -0700

> On Thu, Oct 28, 2010 at 11:22 AM, David Miller <davem@davemloft.net> =
wrote:
>>
>> - =A0 =A0 =A0 int tot_len =3D 0;
>> + =A0 =A0 =A0 size_t tot_len =3D 0;
>=20
> I would actually keep "tot_len" as an "int".
 ...
>> +int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockad=
dr *address, int mode)
>> =A0{
>> =A0 =A0 =A0 =A0int size, ct;
>> - =A0 =A0 =A0 long err;
>> + =A0 =A0 =A0 size_t err;
>=20
> Same thing here. Making "err" be an "int" is actually the right thing
> to do, because then it matches the return type (iow, if it was any
> other type, there would be an implicit cast, and if it didn't fit in
> "int", that would be a bug anyway).

Yep, agreed on all counts, I'll make those changes.
