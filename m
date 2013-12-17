From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Tue, 17 Dec 2013 15:46:24 +0800
Message-ID: <52B00150.3070002@cn.fujitsu.com>
References: <1387182666-31301-1-git-send-email-roy.qing.li@gmail.com> <52AFC43C.9080804@cn.fujitsu.com> <CAJFZqHwF0ubvxJOs2BWbSMMB1szKNO=XTiXje3E2ByF6sUQrXA@mail.gmail.com> <52AFE7E3.3070806@cn.fujitsu.com> <CAJFZqHxawisUbHGZY8mjGHy8035X6TQ7FNzc20vtS5j1jdZYGA@mail.gmail.com> <20131217070231.GA11970@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: RongQing Li <roy.qing.li@gmail.com>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:8782 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751001Ab3LQHqY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 02:46:24 -0500
In-Reply-To: <20131217070231.GA11970@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2013 03:02 PM, Hannes Frederic Sowa wrote:
> On Tue, Dec 17, 2013 at 02:42:01PM +0800, RongQing Li wrote:
>> On 12/17/13, Gao feng <gaofeng@cn.fujitsu.com> wrote:
>>> On 12/17/2013 11:32 AM, RongQing Li wrote:
>>>> If the ort->rt6i_flags is RTF_EXPIRES|RTF_ADDRCONF, then rt6_set_f=
rom will
>>>> not
>>>> be called, and new created rt will have RTF_EXPIRES, but dst.expir=
es is 0,
>>>> and
>>>> dst.from is NULL
>>>
>>> Ok, but I think you need to add more detail/test purpose of the tes=
t case
>>> v6LC.4.1.4
>>> { Reduce PMTU On-link }. just the number of test case is not good f=
or people
>>> to know
>>> what's the real problem.
>>>
>>
>> I have a question, why does we set dst.from only when the ort has fl=
ag
>> RTF_ADDRCONF
>> and RTF_DEFAULT?
>=20
> Good question. ;)
>=20
> I wonder, too. In the past from and expires were a union and either f=
rom or
> expires was allowed to be used. In the commit you referred to this un=
ion was
> split into seperate fields.
>=20
> It somehow worked in the past because routes normally have longer tim=
eouts
> and the routes will get evicted from the route cache eventually. My g=
uess
> is that we can set from unconditionally or copy over the expires valu=
e.
>=20
> This patch already needed quite a long time to review for me and I am=
 still
> unsure. :/
>=20
> Gao, do you still remember why you used RTF_ADDRCONF|RTF_DEFAULT?
>=20

It's a mystery=EF=BC=8C I noticed this problem when I wrote the codes.
http://lists.openwall.net/netdev/2012/03/19/7

I used the flags RTF_ADDRCONF|RTF_DEFAULT because they are exist in
rt6_{get,add,purge}_dflt_router.

The from of new cloned rt should not be set if it's impossible for the =
ort
to be expired.

but seems we should set from if flags have RTF_ADDRCONF bit. RA package
not only generate the default route.
