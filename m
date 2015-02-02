From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3, ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Mon, 02 Feb 2015 11:45:25 -0800 (PST)
Message-ID: <20150202.114525.802784021121531832.davem@davemloft.net>
References: <54CA0B9F.8080104@6wind.com>
	<20150202084443.GS13046@secunet.com>
	<54CF3D3A.5040607@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steffen.klassert@secunet.com, fan.du@intel.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932946AbbBBTp2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 14:45:28 -0500
In-Reply-To: <54CF3D3A.5040607@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 02 Feb 2015 10:02:50 +0100

> Le 02/02/2015 09:44, Steffen Klassert a =E9crit :
>> On Thu, Jan 29, 2015 at 11:29:51AM +0100, Nicolas Dichtel wrote:
> [snip]
>>>
>>> The point I try to make is that patching userland apps allows to us=
e
>>> xfrm on a
>>> 32bits userland / 64bits kernel.
>>
>> Ugh, I did not know that this is used that way. Which applications d=
o
>> this?
>> So the situation is worse than I thought. What happens to such
>> applications
>> if we add a compat layer in the kernel? I'd guess they will break,
>> right?
>
> A compat layer will be perfect. I just wanted to highlight the fact
> that without this patch, it's possible to have a workaround to use
> netlink-xfrm and after it, it will be impossible.

Just a little history, there was a case where we tried to work around t=
his
in userspace by messing with the structure definitions when building
the userland binaries, and that completely exploded.  This was with
the wireless extensions about 15 years ago.

If you work around it in userspace, then you can't fix the kernel to
do the right thing without potentially breaking things again for
the work around binaries that have been created.
