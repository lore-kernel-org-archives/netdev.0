From: pchavent <Paul.Chavent@onera.fr>
Subject: Re: [PATCH net-next] packet mmap : allow the user to choose tx data
 offset.
Date: Sat, 20 Oct 2012 19:13:02 +0200
Message-ID: <535a652cffb4d52cbae20e06a95d724d@sybille.onecert.fr>
References: <1350631302-16280-1-git-send-email-paul.chavent@onera.fr>
 <CAD6jFURov5oB+ck33JzCYQoBo9mYsEM9c0rHz9gmcgdMKgmwCg@mail.gmail.com>
 <50815908.1050308@onera.fr>
 <CAD6jFURS6FXvZJttxEn-qPP5=sWCOHSx=BeSgiJM+ZemAkuKdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Daniel Borkmann <danborkmann@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:57178 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756065Ab2JTRN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 13:13:28 -0400
In-Reply-To: <CAD6jFURS6FXvZJttxEn-qPP5=sWCOHSx=BeSgiJM+ZemAkuKdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel

>>>> +                       switch (po->tp_version) {
>>>> +                       case TPACKET_V2:
>>>> +                               off = ph.h2->tp_mac;
>>>> +                               break;
>>>> +                       default:
>>>> +                               off = ph.h1->tp_mac;
>>>
>>>
>>> TPACKET_V1 as default is wrong since there's also TPACKET_V3. What
>>> about TPACKET_V3 in general in your patch? You simply ignore it.
>>
>>
>> I have reproduced the pattern found some lines above (1868-1875)
>>
>> switch (po->tp_version) {
>> case TPACKET_V2:
>>         tp_len = ph.h2->tp_len;
>>         break;
>> default:
>>         tp_len = ph.h1->tp_len;
>>         break;
>> }
>>
>> Do you suggest me to add a case TPACKET_V3 and get tp_len from 
>> ph.h3->tp_len
>> ?
>
> If I'm not mistaken, with your current patch you can do the
> setsockopt(2) call on a tpacket v3 socket and then default to a
> tpacket v1 in your switch statement. This doesn't seem right. Thus,
> this should better be fixed in whatever way.

It seems that "Opening a Tx-ring is NOT supported in TPACKET_V3" (see 
comment in packet_set_ring). So no one could be able to use the TX_OFF 
feature with a TPACKET_V3.

The tpacket_snd function call some subroutines that call WARN and BUG 
(like in __packet_set_status),
and other ones that simply ignore the tpacket v3 case (like in 
tpacket_fill_skb).

What do you suggest ?

I add a case that call WARN and BUG like in {__packet_set_status, 
__packet_get_status, packet_increment_rx_head} where we get tp_len in 
the tpacket_fill_skb function ?

Or i let the code as is ?

Regards.

Paul.
