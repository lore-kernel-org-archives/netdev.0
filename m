From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 1/8] net: Clarification of CHECKSUM_UNNECESSARY
Date: Mon, 25 Aug 2014 18:47:35 -0700
Message-ID: <CA+mtBx9GvHpLJ718hV5BjRGjfWvmXB55hKa3Rwo=6me3f0M3Dw@mail.gmail.com>
References: <alpine.DEB.2.02.1408251738110.5541@tomh.mtv.corp.google.com>
	<20140825.181341.304248903530349010.davem@davemloft.net>
	<CA+mtBx8iv8tWU0mmEQEWxDfp614Hh=cQOpXqxSdhHaGsH6sBDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:45151 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416AbaHZBrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 21:47:36 -0400
Received: by mail-ie0-f179.google.com with SMTP id rl12so10852330iec.38
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 18:47:36 -0700 (PDT)
In-Reply-To: <CA+mtBx8iv8tWU0mmEQEWxDfp614Hh=cQOpXqxSdhHaGsH6sBDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 25, 2014 at 6:40 PM, Tom Herbert <therbert@google.com> wrote:
> On Mon, Aug 25, 2014 at 6:13 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <therbert@google.com>
>> Date: Mon, 25 Aug 2014 17:55:56 -0700 (PDT)
>>
>>> @@ -569,16 +590,13 @@ struct sk_buff {
>>>       __u8                    wifi_acked:1;
>>>       __u8                    no_fcs:1;
>>>       __u8                    head_frag:1;
>>> -     /* Encapsulation protocol and NIC drivers should use
>>> -      * this flag to indicate to each other if the skb contains
>>> -      * encapsulated packet or not and maybe use the inner packet
>>> -      * headers if needed
>>> -      */
>>> +     /* Indicates the the inner headers are valid in the skbuff. */
>>>       __u8                    encapsulation:1;
>>>       __u8                    encap_hdr_csum:1;
>>>       __u8                    csum_valid:1;
>>>       __u8                    csum_complete_sw:1;
>>> -     /* 2/4 bit hole (depending on ndisc_nodetype presence) */
>>> +     __u8                    csum_level:2;
>>> +     /* 0/2 bit hole (depending on ndisc_nodetype presence) */
>>>       kmemcheck_bitfield_end(flags2);
>>
>> Crap, with xmit_more, this actually bleeds us over into a new __u8.
>
> We'll undoubtably want to add more flags beyond that (they're quite
> useful). I'll try to find some more space in the existing fields so we
> don't increase skbuf size.

Actually, from inner_protocol through mac_header there are seven 16
bit fields, could put another 16 bit flags there.
