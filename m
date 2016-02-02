From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: Allow flow dissector to handle non 4-byte
 aligned headers
Date: Tue, 2 Feb 2016 14:41:23 +0100
Message-ID: <56B0B203.3060700@stressinduktion.org>
References: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
 <20160202003127.GA25154@oracle.com>
 <CAKgT0UfjLEBUeiV3WS2BC=yRkxi9JBF4mqJ=niXOUQnhkiMhvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:51798 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753179AbcBBNlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 08:41:25 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id E434221259
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2016 08:41:24 -0500 (EST)
In-Reply-To: <CAKgT0UfjLEBUeiV3WS2BC=yRkxi9JBF4mqJ=niXOUQnhkiMhvA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.02.2016 04:56, Alexander Duyck wrote:
>> @@ -394,7 +407,7 @@ ip_proto_again:
>>                                                     data, hlen, &_eth);
>>                          if (!eth)
>>                                  goto out_bad;
>> -                       proto = eth->h_proto;
>> +                       proto = get_unaligned_be16(&eth->h_proto);
>>                          nhoff += sizeof(*eth);
>>                  }
>
> This piece doesn't make any sense to me.  It is already only 2 bytes
> wide.  I'm not sure why we should be seeing this trigger an unaligned
> access.  Are you sure it wasn't something like the keyid causing the
> issue?  I'd be interested in seeing what the compiler did here that it
> is triggering the problem.
>

Correct, and the __packed attribute of struct ethhdr already causes all 
members to have an assumed-alignment of '1', so gcc doesn't create any 
16 bit width accesses anyway.

Bye,
Hannes
