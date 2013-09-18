From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v2 6/6] ipv6: Do route updating for redirect in ndisc
 layer
Date: Wed, 18 Sep 2013 09:52:42 +0800
Message-ID: <5239076A.4080406@cn.fujitsu.com>
References: <52327F00.4040802@cn.fujitsu.com> <5232806B.6050601@cn.fujitsu.com> <20130917.202936.2080212548361553334.davem@davemloft.net> <20130918013903.GC8947@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:36613 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750942Ab3IRBxo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 21:53:44 -0400
In-Reply-To: <20130918013903.GC8947@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B409=E6=9C=8818=E6=97=A5 09:39, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Tue, Sep 17, 2013 at 08:29:36PM -0400, David Miller wrote:
>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>> Date: Fri, 13 Sep 2013 11:03:07 +0800
>>
>>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>>
>>> Do the whole verification and route updating in ndisc
>>> lay and then just call into icmpv6_notify() to notify
>>> the upper protocols.
>>>
>>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>
>> This is completely broken, and I believe your patch set fundamentall=
y
>> is too.
>>
>> We absolutely _must_ handle the redirect at the socket level when
>> we are able to, otherwise we cannot specify the mark properly and
>> the mark is an essential part of the key used to find the correct
>> route to work with.
>>
>> I am not applying this patch series until you deal with this
>> deficiency.  I am not willing to consider changes which stop using t=
he
>> more precise keying information available from a socket.
>=20
> Oh, Duan, I am very sorry for not catching this earlier. We use the
> sk->mark to select the proper routing table where we clone the rt6_in=
fo into.
> And we only get that value out of the sockets. I missed that. We shou=
ld leave
> the redirect logic in the socket layer where it is possible.
>=20
> But parts of this series are still valid. We need to fix redirects fo=
r tunnels
> and I do think we can still simplify some code in the error handlers.
>=20

I got it.

Thanks,
  Duan
