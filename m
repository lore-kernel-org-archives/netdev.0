From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [Suggestion] net/atm : for sprintf, need check the total write
 length whether larger than a page.
Date: Wed, 5 Dec 2012 09:55:03 -0500
Message-ID: <20121205095503.6d1c083d@thirdoffive.cmf.nrl.navy.mil>
References: <201212050357.qB53vHvT022706@thirdoffive.cmf.nrl.navy.mil>
	<50BED40D.9080100@asianux.com>
	<50BEDE4E.8010408@asianux.com>
	<50BEE2BE.2030704@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:44144 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997Ab2LEOzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 09:55:14 -0500
In-Reply-To: <50BEE2BE.2030704@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Dec 2012 13:59:26 +0800
Chen Gang <gang.chen@asianux.com> wrote:

> =D3=DA 2012=C4=EA12=D4=C205=C8=D5 13:40, Chen Gang =D0=B4=B5=C0:
> > =D3=DA 2012=C4=EA12=D4=C205=C8=D5 12:56, Chen Gang =D0=B4=B5=C0:
> >>>>>>>> -		pos +=3D sprintf(pos, "\n");
> >>>>>>>> +		count +=3D scnprintf(buf + count, PAGE_SIZE - count, "\n"=
);
> >>>> ..
> >>>>>>  need we judge whether count >=3D PAGE_SIZE ?
> >>>>
> >>>> count will eventually make PAGE_SIZE - count reach 0 at which po=
int,
> >>>> scnprintf() won't be able to write into the buffer.
> >>   I also think so.
> >>
> >>   I think, maybe it will be better to break the loop when we alrea=
dy
> >> know that "count >=3D PAGE_SIZE" (it can save waste looping, altho=
ugh it
> >> seems unlikly happen, for example, using unlikly(...) ).

it doesn't seem like optimizing for this corner case is a huge
concern.  the list cannot be infinitely long.

> >>
> >> By the way:
> >>   will it be better that always let "\n" at the end ?
> >>   (if count =3D=3D PAGE_SIZE in a loop, we can not let "\n" at the=
 end).
> >=20
> >    oh, sorry ! count will never >=3D PAGE_SIZE.
> >=20
> >    I think let "PAGE_SIZE - 2" instead of "PAGE_SIZE" in the loop, =
so we
> > can make the room for the end of "\n".
> >=20
> >=20
> >=20
>    sorry, "PAGE_SIZE - 1" is enough, not need "PAGE_SIZE - 2".

did you mean '\0' instead of '\n'?  scnprintf() considers the trailing
'\0' when formatting.
