From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] net/atm : for sprintf, need check the total write
 length whether larger than a page.
Date: Wed, 05 Dec 2012 13:40:30 +0800
Message-ID: <50BEDE4E.8010408@asianux.com>
References: <201212050357.qB53vHvT022706@thirdoffive.cmf.nrl.navy.mil> <50BED40D.9080100@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:19020 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217Ab2LEFjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 00:39:37 -0500
In-Reply-To: <50BED40D.9080100@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2012=C4=EA12=D4=C205=C8=D5 12:56, Chen Gang =D0=B4=B5=C0:
>>>> >>> -		pos +=3D sprintf(pos, "\n");
>>>> >>> +		count +=3D scnprintf(buf + count, PAGE_SIZE - count, "\n");
>> > ..
>>> >>  need we judge whether count >=3D PAGE_SIZE ?
>> >=20
>> > count will eventually make PAGE_SIZE - count reach 0 at which poin=
t,
>> > scnprintf() won't be able to write into the buffer.
>   I also think so.
>=20
>   I think, maybe it will be better to break the loop when we already
> know that "count >=3D PAGE_SIZE" (it can save waste looping, although=
 it
> seems unlikly happen, for example, using unlikly(...) ).
>=20
> By the way:
>   will it be better that always let "\n" at the end ?
>   (if count =3D=3D PAGE_SIZE in a loop, we can not let "\n" at the en=
d).

   oh, sorry ! count will never >=3D PAGE_SIZE.

   I think let "PAGE_SIZE - 2" instead of "PAGE_SIZE" in the loop, so w=
e
can make the room for the end of "\n".



--=20
Chen Gang

Asianux Corporation
