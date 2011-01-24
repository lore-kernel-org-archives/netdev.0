From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] GRO: fix merging a paged skb after non-paged skbs
Date: Mon, 24 Jan 2011 14:27:41 -0800 (PST)
Message-ID: <20110124.142741.71100065.davem@davemloft.net>
References: <1295894693.2755.58.camel@edumazet-laptop>
	<20110124230848.577187e9@delilah>
	<1295907745.2924.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mschmidt@redhat.com, netdev@vger.kernel.org,
	herbert@gondor.hengli.com.au, bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43535
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751487Ab1AXW1H convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jan 2011 17:27:07 -0500
In-Reply-To: <1295907745.2924.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Jan 2011 23:22:25 +0100

> Le lundi 24 janvier 2011 =E0 23:08 +0100, Michal Schmidt a =E9crit :
>> Suppose that several linear skbs of the same flow were received by G=
RO. They
>> were thus merged into one skb with a frag_list. Then a new skb of th=
e same flow
>> arrives, but it is a paged skb with data starting in its frags[].
>>=20
>> Before adding the skb to the frag_list skb_gro_receive() will of cou=
rse adjust
>> the skb to throw away the headers. It correctly modifies the page_of=
fset and
>> size of the frag, but it leaves incorrect information in the skb:
>>  ->data_len is not decreased at all.
>>  ->len is decreased only by headlen, as if no change were done to th=
e frag.
>> Later in a receiving process this causes skb_copy_datagram_iovec() t=
o return
>> -EFAULT and this is seen in userspace as the result of the recv() sy=
scall.
>>=20
>> In practice the bug can be reproduced with the sfc driver. By defaul=
t the
>> driver uses an adaptive scheme when it switches between using
>> napi_gro_receive() (with skbs) and napi_gro_frags() (with pages). Th=
e bug is
>> reproduced when under rx load with enough successful GRO merging the=
 driver
>> decides to switch from the former to the latter.
>>=20
>> Manual control is also possible, so reproducing this is easy with ne=
tcat:
>>  - on machine1 (with sfc): nc -l 12345 > /dev/null
>>  - on machine2: nc machine1 12345 < /dev/zero
>>  - on machine1:
>>    echo 1 > /sys/module/sfc/parameters/rx_alloc_method  # use skbs
>>    echo 2 > /sys/module/sfc/parameters/rx_alloc_method  # use pages
>>  - See that nc has quit suddenly.
>>=20
>> [v2: Modified by Eric Dumazet to avoid advancing skb->data past the =
end
>>      and to use a temporary variable.]
>>=20
>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
 ...
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks!
