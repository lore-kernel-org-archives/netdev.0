From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6, token: allow for clearing the current
 device token
Date: Fri, 8 Apr 2016 17:36:22 +0200
Message-ID: <5707CFF6.6090707@stressinduktion.org>
References: <307b4d32099f606d0fbe0ce9fecd3a039b796361.1460123261.git.daniel@iogearbox.net>
 <878u0otc96.fsf@nemi.mork.no>
 <1460126038.1452331.572938089.68D8127C@webmail.messagingengine.com>
 <874mbct95a.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	robbat2@gentoo.org, netdev@vger.kernel.org
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:58218 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755464AbcDHPgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 11:36:25 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 155AE2103B
	for <netdev@vger.kernel.org>; Fri,  8 Apr 2016 11:36:24 -0400 (EDT)
In-Reply-To: <874mbct95a.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.04.2016 17:25, Bj=C3=B8rn Mork wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
>
>> On Fri, Apr 8, 2016, at 16:18, Bj=C3=B8rn Mork wrote:
>>> Daniel Borkmann <daniel@iogearbox.net> writes:
>>>
>>>>
>>>>   	if (!token)
>>>>   		return -EINVAL;
>>>> -	if (ipv6_addr_any(token))
>>>> -		return -EINVAL;
>>>>   	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP))
>>>>   		return -EINVAL;
>>>
>>> Not directly related to the patch in question.  It just made me awa=
re of
>>> this restriction...
>>>
>>> I realize that I'm a few years late here, but what's with the IFF_N=
OARP?
>>> Is that just because we can't do DAD for the token based addresses?=
  How
>>> is that different from manually configuring the whole address?
>>
>> IFF_NOARP is kind of the equivalent to no neighbor discovery. If you=
 set
>> a token and never get in a router advertisement you never create a
>> tokenized ip address, thus the feature is useless.
>
> You can get router advertisements with IFF_NOARP. You cannot lookup L=
2
> addresses, but the L3 prefix info is still as useful as with any othe=
r
> interface.

Of course router advertisements can be send and received with IFF_NOARP=
=20
and probably we act on them as usual, as you showed. Looking in the=20
source we don't really specify what those flags mean/do for IPv6. So I=20
think you can assume that it is in there because of history.

I would absolutely not mind if you remove the limitation for IFF_ARP.

Bye,
Hannes
