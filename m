From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [STABLE 2.6.32 PATCH] net: release dst entry while cache-hot
 for GSO case too
Date: Mon, 11 Oct 2010 20:55:19 +0400
Message-ID: <4CB34177.6030902@msgid.tls.msk.ru>
References: <1286810413-30238-1-git-send-email-avagin@openvz.org>	 <4CB32FDB.4090001@msgid.tls.msk.ru>	 <1286812009.2737.30.camel@edumazet-laptop>	 <20101011.085952.193718228.davem@davemloft.net>	 <4CB33907.5060803@gmail.com> <1286814652.2737.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: avagin@gmail.com, David Miller <davem@davemloft.net>,
	avagin@openvz.org, stable@kernel.org, netdev@vger.kernel.org,
	krkumar2@in.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:59445 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754888Ab0JKQzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 12:55:23 -0400
In-Reply-To: <1286814652.2737.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

11.10.2010 20:30, Eric Dumazet wrote:
> Le lundi 11 octobre 2010 =C3=A0 20:19 +0400, Andrew Vagin a =C3=A9cri=
t :
>> On 10/11/2010 07:59 PM, David Miller wrote:
>>> From: Eric Dumazet<eric.dumazet@gmail.com>
>>> Date: Mon, 11 Oct 2010 17:46:49 +0200
>>>
>>>> This patch was an optimization, not a bug fix.
>>> Right, this has no business going into 2.6.32-stable at all.
>> This is bug fix. Now nobody drops dst in case gso and veth, because =
the=20
>> commit 60df914e295a21a223e43a7ee01e0c73c64dd111 deletes skb_dst_drop=
=20
>> from the veth.c. We should commit my patch or revert commit 60df914e=
=2E
>>
>> We have two bug reports:
>>
>> http://www.spinics.net/lists/netdev/msg142104.html

This is korg#17251: https://bugzilla.kernel.org/show_bug.cgi?id=3D17251=
 ,
from me.

But I really wonder how that thing does not happen anymore
when I disabled netfilter hooks...  I can't experiment till
weekend, but I'll try to get back to it and re-verify again,
with and without this fix, with and without netfilter hooks.

What I know for sure is 2 facts: I can't trigger the problem
now (with the hooks disabled), and I can't trigger it on a
subsequent kernel releases - e.g. 2.6.35 does not have the
issue, but 2.6.32 has.

>> http://bugzilla.openvz.org/show_bug.cgi?id=3D1634

Thanks!

/mjt
