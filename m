From: Fan Du <fan.du@windriver.com>
Subject: Re: [DISCUSSION] rt6i_genid
Date: Fri, 19 Jul 2013 11:28:51 +0800
Message-ID: <51E8B273.1090002@windriver.com>
References: <51E7B522.4070105@windriver.com>	<51E805D9.9040408@6wind.com>	<51E881EB.5040600@windriver.com> <20130718.201801.1591610112107900505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nicolas.dichtel@6wind.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:36760 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934990Ab3GSD2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 23:28:25 -0400
In-Reply-To: <20130718.201801.1591610112107900505.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B407=E6=9C=8819=E6=97=A5 11:18, David Miller wrote:
> From: Fan Du<fan.du@windriver.com>
> Date: Fri, 19 Jul 2013 08:01:47 +0800
>
>>
>>
>> On 2013=E5=B9=B407=E6=9C=8818=E6=97=A5 23:12, Nicolas Dichtel wrote:
>>> Le 18/07/2013 11:28, Fan Du a =C3=A9crit :
>>>>
>>>> Thanks for replying :)
>>>>
>>>> On 2013=E5=B9=B407=E6=9C=8818=E6=97=A5 17:13, Nicolas Dichtel wrot=
e:
>>>>> Le 18/07/2013 05:22, Fan Du a =C3=A9crit :
>>>>>> Hello Nicolas
>>>>>>
>>>>>> Commit 6f3118b571b8a4c06c7985dc3172c3526cb86253: "ipv6: use
>>>>>> net->rt_genid to
>>>>>> check dst validity"
>>>>>> makes ip6_dst_check to check rt6i_genid against with struct
>>>>>> net->rt_genid,
>>>>>> As a matter of fact, struct net->rt_genid could only be modified=
 by
>>>>>> two places,
>>>>>> first is adding/delete IPv4 address, second is inserting new XFR=
M
>>>>>> policy.
>>>>>>
>>>>>> Is there any other considerations that adding/deleting IPv4 addr=
ess
>>>>>> would
>>>>>> invalid all IPv6 dst
>>>>>> as well? because I'm working a patch which actually depends on t=
he
>>>>>> result of
>>>>>> this question.
>>>>> No, the goal was to cover the IPsec case, ie invalidate dst entri=
es
>>>>> when an
>>>>> xfrm policy is inserted/deleted.
>>>>
>>>> Ok, then how about we only checking rt6i_genid against rt_genid *o=
nly*
>>>> when XFRM is enabled for IPv6, because when XFRM is not enabled fo=
r
>>>> IPv6
>>>> ip6_dst_check for rt_genid is really not necessary.
>>>>
>>>> So what do you think of below modifications?
>>> Seems good. Just a small comment below.
>>
>> Will send v2 for your reviewing when net-next is reopen.
>
> Although it's a correct change, it is of almost no value.  %99.999999=
9
> of users will be running kernels with CONFIG_XFRM enabled.

Thanks. Good to know %99.99999999 users protect their networking with I=
Psec.

> So your savings are essentially for no-one.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
