From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next] ip6_tunnel: ensure to always have a link local address
Date: Wed, 21 Aug 2013 11:02:52 +0200
Message-ID: <87haej76wz.fsf@nemi.mork.no>
References: <1376993766-5723-1-git-send-email-nicolas.dichtel@6wind.com>
	<20130820.234818.2230621827416764963.davem@davemloft.net>
	<52146EE9.1060101@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:59903 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751534Ab3HUJDL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 05:03:11 -0400
In-Reply-To: <52146EE9.1060101@6wind.com> (Nicolas Dichtel's message of "Wed,
	21 Aug 2013 09:40:25 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
> Le 21/08/2013 08:48, David Miller a =C3=A9crit :
>
>> Applied, but this brings up an issue I keep noticing.
>>
>> We talk about eth_random_addr() and "uniqueness" together all the
>> time, but the former never implies the latter.
>>
>> And we're going to run into situations where any conflicts generated
>> by this random address generater will cause reall failures.
>>
>> Therefore we'll have to create a system to prevent them.  Probably
>> using some simple table that keeps track of the addresses we've
>> generated.
>>
> Ok, I will look at this.

Are eth_random_addr() collisions really any different than interfaces
having the same address for other reasons? Reality is that we never can
trust a mac address to be truly unique, regardless of source.  And most
of the time it doesn't matter.  There is no problem with two interfaces
having the same link local address as long as they are on different
links, for example.

What's important is that we deal with collisions gracefully in cases
where they do matter, allowing an administrator to fix the issue.  I
believe we already do that on DAD failure with any mac address derived
link local address, disabling IPv6 and logging the reason.=20


Bj=C3=B8rn
