From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: make connect() mem charging friendly
Date: Wed, 19 Nov 2014 14:57:41 -0500 (EST)
Message-ID: <20141119.145741.1905980604994551607.davem@davemloft.net>
References: <1416268176.18588.26.camel@edumazet-glaptop2.roam.corp.google.com>
	<1416294380.14060.6.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAK6E8=dUvde2s7VuUS9rHiA2fU0ZT2bS=ronjM+9BOA=0u-rVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, nuclearcat@nuclearcat.com,
	netdev@vger.kernel.org, ncardwell@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38109 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755182AbaKST5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 14:57:44 -0500
In-Reply-To: <CAK6E8=dUvde2s7VuUS9rHiA2fU0ZT2bS=ronjM+9BOA=0u-rVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 19 Nov 2014 14:10:42 +0800

> On Tue, Nov 18, 2014 at 3:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> While working on sk_forward_alloc problems reported by Denys
>> Fedoryshchenko, we found that tcp connect() (and fastopen) do not call
>> sk_wmem_schedule() for SYN packet (and/or SYN/DATA packet), so
>> sk_forward_alloc is negative while connect is in progress.
>>
>> We can fix this by calling regular sk_stream_alloc_skb() both for the
>> SYN packet (in tcp_connect()) and the syn_data packet in
>> tcp_send_syn_data()
>>
>> Then, tcp_send_syn_data() can avoid copying syn_data as we simply
>> can manipulate syn_data->cb[] to remove SYN flag (and increment seq)
>>
>> Instead of open coding memcpy_fromiovecend(), simply use this helper.
>>
>> This leaves in socket write queue clean fast clone skbs.
>>
>> This was tested against our fastopen packetdrill tests.
>>
>> Reported-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
> 
> Thanks! this simplifies the code a lot.

Agreed, applied, thanks everyone!
