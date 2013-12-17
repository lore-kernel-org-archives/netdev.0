From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Tue, 17 Dec 2013 17:23:37 +0800
Message-ID: <52B01819.8030602@cn.fujitsu.com>
References: <1387182666-31301-1-git-send-email-roy.qing.li@gmail.com> <52AFC43C.9080804@cn.fujitsu.com> <CAJFZqHwF0ubvxJOs2BWbSMMB1szKNO=XTiXje3E2ByF6sUQrXA@mail.gmail.com> <52AFE7E3.3070806@cn.fujitsu.com> <CAJFZqHxawisUbHGZY8mjGHy8035X6TQ7FNzc20vtS5j1jdZYGA@mail.gmail.com> <20131217070231.GA11970@order.stressinduktion.org> <52B00150.3070002@cn.fujitsu.com> <20131217083048.GB18396@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: RongQing Li <roy.qing.li@gmail.com>
To: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:9542 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750950Ab3LQJXi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 04:23:38 -0500
In-Reply-To: <20131217083048.GB18396@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2013 04:30 PM, Hannes Frederic Sowa wrote:
> On Tue, Dec 17, 2013 at 03:46:24PM +0800, Gao feng wrote:
>>> Gao, do you still remember why you used RTF_ADDRCONF|RTF_DEFAULT?
>>>
>>
>> It's a mystery=EF=BC=8C I noticed this problem when I wrote the code=
s.
>> http://lists.openwall.net/netdev/2012/03/19/7
>=20
> I already found this thread, thanks. ;)
>=20
>> I used the flags RTF_ADDRCONF|RTF_DEFAULT because they are exist in
>> rt6_{get,add,purge}_dflt_router.
>=20
> I thought so, but we have to deal with !DEFAULT ADDRCONF routes, too.

Right.

>=20
>> The from of new cloned rt should not be set if it's impossible for t=
he ort
>> to be expired.
>=20
> Ok.
>=20
>> but seems we should set from if flags have RTF_ADDRCONF bit. RA pack=
age
>> not only generate the default route.
>=20
> Exactly, but it is worse:
>=20
> Prefix routes can be added with expiration time if user space install=
s a
> prefix with valid_lft !=3D infinity. So I fear we already have permam=
ent route
> entries which expire.

Yes, this should happen..
>=20
> Userspace router advertisment listener already use that.
>=20
> I fear the flags don't have a well defined semantic any more. :(
>=20
> As for the original patch in this thread, I would suggest to hold it
> back until this mess is understood. Ok?
>=20

I'm ok if we want the behave back to the commit 1716a96101[ipv6: fix pr=
oblem with
expired dst cache].
