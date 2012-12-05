From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] net/atm : for sprintf, need check the total write
 length whether larger than a page.
Date: Wed, 05 Dec 2012 12:56:45 +0800
Message-ID: <50BED40D.9080100@asianux.com>
References: <201212050357.qB53vHvT022706@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:28150 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813Ab2LEEzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 23:55:52 -0500
In-Reply-To: <201212050357.qB53vHvT022706@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2012=C4=EA12=D4=C205=C8=D5 11:57, Chas Williams (CONTRACTOR) =D0=
=B4=B5=C0:
> In message <50BEA2CB.9000800@asianux.com>,Chen Gang writes:
>>> -	for (i =3D 0; i < (ESI_LEN - 1); i++)
>>> -		pos +=3D sprintf(pos, "%02x:", adev->esi[i]);
>>> -	pos +=3D sprintf(pos, "%02x\n", adev->esi[i]);
>>> =20
>>> -	return pos - buf;
>>> +	return scnprintf(buf, PAGE_SIZE, "%pM\n", adev->esi);
>>>  }
>>> =20
>>
>>  "%p" seems print a pointer, not contents of pointer (is it correct =
?)
>>  will it change the original display format to outside ?
>=20
> %pM means format this pointer as a mac address.  it didnt exist when =
the
> atm stack was originally written but can be used now to save a bit of
> messy code.
>=20

  it is my fault. thank you

  :-)


>>> -		pos +=3D sprintf(pos, "\n");
>>> +		count +=3D scnprintf(buf + count, PAGE_SIZE - count, "\n");
> ..
>>  need we judge whether count >=3D PAGE_SIZE ?
>=20
> count will eventually make PAGE_SIZE - count reach 0 at which point,
> scnprintf() won't be able to write into the buffer.

  I also think so.

  I think, maybe it will be better to break the loop when we already
know that "count >=3D PAGE_SIZE" (it can save waste looping, although i=
t
seems unlikly happen, for example, using unlikly(...) ).

By the way:
  will it be better that always let "\n" at the end ?
  (if count =3D=3D PAGE_SIZE in a loop, we can not let "\n" at the end)=
=2E



  I think what I said above are minor, if you think, for this patch, do
not need consider them, it is ok (at least for me, it is true).

  :-)

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20


--=20
Chen Gang

Asianux Corporation
