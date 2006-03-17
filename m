From: Scott Bardone <sbardone@chelsio.com>
Subject: Re: drivers/net/chelsio/sge.c: two array overflows
Date: Fri, 17 Mar 2006 10:46:18 -0800
Message-ID: <441B03FA.9020004@chelsio.com>
References: <20060311013720.GG21864@stusta.de> <4415C87B.90107@chelsio.com> <441A011A.6010705@pobox.com> <200603171319.20935.hpj@urpla.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, Adrian Bunk <bunk@stusta.de>,
	maintainers@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750905AbWCQSsB@vger.kernel.org>
To: Hans-Peter Jansen <hpj@urpla.net>
In-Reply-To: <200603171319.20935.hpj@urpla.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Pete,

This is correct, the array should contain 3 elements. The bug was we we=
re=20
accessing a 4th element ([3]) which did not exist. We should be modifyi=
ng the=20
last element ([2]) instead.

-Scott

Hans-Peter Jansen wrote:
> [from the nitpick department..]
>=20
> Hi Jeff, hi Scott,
>=20
> Adrian wrote:
>=20
>>The Coverity checker spotted the following two array overflows in=20
>>drivers/net/chelsio/sge.c (in both cases, the arrays contain 3=20
>>elements):
>=20
>=20
> Am Freitag, 17. M=E4rz 2006 01:21 schrieb Jeff Garzik:
>=20
>>Scott Bardone wrote:
>>
>>>Adrian,
>>>
>>>This is a bug. The array should contain 2 elements.
>>>
>>>Attached is a patch which fixes it.
>>>Thanks.
>>>
>>>Signed-off-by: Scott Bardone <sbardone@chelsio.com>
>>
>>applied.  please avoid attachments and use a proper patch description
>>in the future.  I had to hand-edit and hand-apply your patch.
>=20
>=20
> where you wrote in kernel tree commit=20
> 347a444e687b5f8cf0f6485704db1c6024d3:
> This is a bug. The array should contain 2 elements.  Here is the fix.
>=20
> If I'm not completely off the track, you both committed a description=
=20
> off by one error: since the patch doesn't change the array size, it's=
=20
> presumely=B9 still 3 elements, where index 2 references the last one.
>=20
> Here's hopefully a better patch description:
> Fixed off by one thinko in stats accounting, spotted by Coverity=20
> checker, notified by Adrian "The Cleanman" Bunk.
>=20
> SCR,
> Pete
>=20
> =B9) otherwise, it's still off by one..
