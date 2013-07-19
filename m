From: Fan Du <fan.du@windriver.com>
Subject: Re: [DISCUSSION] rt6i_genid
Date: Fri, 19 Jul 2013 15:50:20 +0800
Message-ID: <51E8EFBC.6040902@windriver.com>
References: <51E881EB.5040600@windriver.com>	<20130718.201801.1591610112107900505.davem@davemloft.net>	<51E8B273.1090002@windriver.com> <20130718.203100.1960741588589171145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nicolas.dichtel@6wind.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:38720 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab3GSHtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 03:49:53 -0400
In-Reply-To: <20130718.203100.1960741588589171145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B407=E6=9C=8819=E6=97=A5 11:31, David Miller wrote:
> From: Fan Du<fan.du@windriver.com>
> Date: Fri, 19 Jul 2013 11:28:51 +0800
>
>> On 2013=E5=B9=B407=E6=9C=8819=E6=97=A5 11:18, David Miller wrote:
>>> Although it's a correct change, it is of almost no value.  %99.9999=
999
>>> of users will be running kernels with CONFIG_XFRM enabled.
>>
>> Thanks. Good to know %99.99999999 users protect their networking wit=
h
>> IPsec.
>
> That is not what I said.
>
> I said that nearly every user will be running a kernel with that
> config option enabled, I did not say that they will actually be
> using IPSEC.
>
> Distributions enable all options, so that users may use any facility
> that they want.
>
> So optimizing for things like this are almost pointless.
>

I've understood the situation/point you're trying to describe.
No problem, I will drop this almost-pointless patch :)

The original commit is targeted for XFRM policy inserting/removing,
but it uses net genid shared by both IPv4 and IPv6, the side effect is
add/delete IPv4 address will invalidate IPv6 dst in all.

We *do* need to bump genid when add/delete IPv6 address in scenario I
described here: http://www.spinics.net/lists/netdev/msg243398.html,
but definitely not from add/delete IPv4 address. Moreover test shows
that DCCP still push thousands of packets on wire after delete its IPv6
address in the same scenario I describe before.

The impulse to bump genid for IPv6 is much more stronger after this
commit even do it unintentionally.

So am I missing some thing more important inside IPv6, Dave?

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
