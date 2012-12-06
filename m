From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] net/atm : for sprintf, need check the total write
 length whether larger than a page.
Date: Thu, 06 Dec 2012 09:15:10 +0800
Message-ID: <50BFF19E.1040405@asianux.com>
References: <201212050357.qB53vHvT022706@thirdoffive.cmf.nrl.navy.mil> <50BED40D.9080100@asianux.com> <50BEDE4E.8010408@asianux.com> <50BEE2BE.2030704@asianux.com> <20121205095503.6d1c083d@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:27980 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444Ab2LFBOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 20:14:17 -0500
In-Reply-To: <20121205095503.6d1c083d@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2012=C4=EA12=D4=C205=C8=D5 22:55, chas williams - CONTRACTOR =D0=
=B4=B5=C0:
> On Wed, 05 Dec 2012 13:59:26 +0800
>=20
> it doesn't seem like optimizing for this corner case is a huge
> concern.  the list cannot be infinitely long.
>=20

  ok.


>>>>
>>>> By the way:
>>>>   will it be better that always let "\n" at the end ?
>>>>   (if count =3D=3D PAGE_SIZE in a loop, we can not let "\n" at the=
 end).
>>>
>>>    oh, sorry ! count will never >=3D PAGE_SIZE.
>>>
>>>    I think let "PAGE_SIZE - 2" instead of "PAGE_SIZE" in the loop, =
so we
>>> can make the room for the end of "\n".
>>>
>>>
>>>
>>    sorry, "PAGE_SIZE - 1" is enough, not need "PAGE_SIZE - 2".
>=20
> did you mean '\0' instead of '\n'?  scnprintf() considers the trailin=
g
> '\0' when formatting.

  no, originally, the end is "\n\0".

  I prefer we still compatible "\n" when the contents are very large.
  if count already =3D=3D (PAGE_SIZE - 1), we have no chance to append =
"\n" to the end.

-		pos +=3D sprintf(pos, "\n");
+		count +=3D scnprintf(buf + count, PAGE_SIZE - count, "\n");


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20


--=20
Chen Gang

Asianux Corporation
