From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next 6/6] net: Implmement RFC 6936 (zero RX csums
 for UDP/IPv6)
Date: Tue, 08 Apr 2014 10:17:03 +0900
Message-ID: <53434E0F.90707@linux-ipv6.org>
References: <alpine.DEB.2.02.1404041720560.21339@tomh.mtv.corp.google.com>	<5342F307.6020407@linux-ipv6.org> <CA+mtBx_gUsovA87Fqpn+zzDzNL7wJ7YWX3_pfcZORg=nexXHcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:37334 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754690AbaDHBRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 21:17:06 -0400
In-Reply-To: <CA+mtBx_gUsovA87Fqpn+zzDzNL7wJ7YWX3_pfcZORg=nexXHcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:

>>>       while (sk) {
>>> +             if (!uh->check && !udp_sk(sk)->check6_zero_okay) {
>>> +                     /*
>>> +                      * If checksum in packet is zero and not all the
>>> +                      * sockets accept a zero checksum then declare
>>> +                      * a checksum error.
>>> +                      */
>>> +                     flush_stack(stack, count, skb, ~0);
>>> +                     count = 0;
>>> +                     udp6_csum_zero_error(skb);
>>> +                     UDP6_INC_STATS_BH(net, UDP_MIB_CSUMERRORS, proto == IPPROTO_UDPLITE);
>>> +                     UDP6_INC_STATS_BH(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
>>> +                     break;
>>> +             }
>>>               stack[count++] = sk;
>>>               sk = udp_v6_mcast_next(net, sk_nulls_next(sk), uh->dest, daddr,
>>>                                      uh->source, saddr, dif);
>>
>> This seems wrong; packets with zero-checksum will not be delivered to
>> some sockets if some of sockets accept zero-checksums and others do not.
>>
> Okay, I suppose delivering to some and not others is reasonable,
> although there's no accounting for the non-deliverables-- I suppose
> there's no completely clean way to do this...

Well, I believe that supporting UDP packets with zero-checksum
should be implemented in a consistent way with UDP-lite.

>> BTW, I have been thinking that we should introduce 4 options
>> (or bits) for IPv4/IPv6 checksumming for sender/receiver.
>>
> What are these 4 options?

I meant combination of {ipv4,ipv6} and {sender,receiver}.

--yoshfuji
