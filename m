From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v4] ipv6:introduce function to find route for redirect
Date: Wed, 04 Sep 2013 20:06:11 +0800
Message-ID: <52272233.20307@cn.fujitsu.com>
References: <52242CE1.5050501@cn.fujitsu.com> <20130902195056.GA5451@order.stressinduktion.org> <5225758F.8080604@cn.fujitsu.com> <20130903191729.GA28889@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:20331 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S934622Ab3IDMGu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 08:06:50 -0400
In-Reply-To: <20130903191729.GA28889@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B409=E6=9C=8804=E6=97=A5 03:17, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Tue, Sep 03, 2013 at 01:37:19PM +0800, Duan Jiong wrote:
>>> Btw. I still think it should be possible to eliminate
>>> ip6_redirect_no_header:
>>>
>>> We could always use ip6_redirect_no_header and use the data of the =
redirected
>>> header option just for finding the socket to be notified. We can do=
 the whole
>>> verification and route updating in ndisc layer and then just call i=
nto icmpv6
>>> layer if upper protocols need a notification of the redirect. But t=
hat should
>>> go into another patch. ;)
>>>
>>
>> I think this is good, but i have a question below:
>>
>>   if the socket type is connection-based, the dst information is sto=
red in related
>> sock struct, so there is no need to look up the route for redirect i=
n ip6_redirect
>> or ip6_redirect_no_header, in this case, we do the verification and =
route=20
>> updating in the upper protocols' err_handler is better.=20
>>
>> How do you think of this?
>=20
> This should not be a problem, because every cached dst should be vali=
dated
> with ip6_dst_check before it is used. It uses the fib6_node serial nu=
mber
> which is incremented for all fib6_nodes on the path to the new instal=
led
> node by fib6_add_1. So we are safe here.
>=20
> Btw. this is the same logic redirects get currently picked up, too.
>=20

Thanks for you answer, but i still have some questions on dealing with =
redirect
in ip4ip6_err() and ipip6_err(), and i need some time to learn more abo=
ut them.
So i only send one patch to fix the bug.

Please forgive me is a newbie.:)

Thanks,
  Duan=20
