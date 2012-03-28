From: Chao Pei <peichao85@gmail.com>
Subject: Re: a F-RTO question
Date: Wed, 28 Mar 2012 13:27:00 +0800
Message-ID: <CAJkE24JXgOtbybWozeq8XKvQy9qUbJDKjcYEtaSWr3pP+ESciQ@mail.gmail.com>
References: <4F7281ED.1060603@gmail.com>
	<CAJkE24+qgK4_cGtiEi6hWDFS2EVYPajHY3pigwh_RqguwsedNg@mail.gmail.com>
	<4F728EC9.1050302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:54552 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750746Ab2C1F1C convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2012 01:27:02 -0400
Received: by lahj13 with SMTP id j13so746882lah.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 22:27:00 -0700 (PDT)
In-Reply-To: <4F728EC9.1050302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>>> Hi,
>>>
>>> =A0 =A0 =A0 =A0I have a question about tcp_process_frto(), the belo=
w source
>>> code :
>>>
>>> static int tcp_process_frto(struct sock *sk, int flag)
>>> {
>>> =A0 =A0 =A0 =A0.....
>>>
>>> =A0 =A0 =A0 =A0if (!before(tp->snd_una, tp->frto_highmark)) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_enter_frto_loss(sk, ...);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
>>> =A0 =A0 =A0 =A0}
>>>
>>> =A0 =A0 =A0 =A0.....
>>>
>>> }
>>>
>>> =A0 =A0 =A0 =A0As my understanding, the tp->frto_highmark likes tp-=
>high_seq,
>>> it saves the seqno SND_NXT when a TCP connection enters F-RTO phase=
,
>>> is it the variable "recovery" in NewReno? So I think that if snd_un=
a is
>>> equal with or after frto_highmark, which means peer ack new data, s=
o
>>> why we enter Loss state here?
>>>
>>> =A0 =A0 =A0 =A0Thanks!
>>>
>>> Yu
>>>
>>>
>>
>> If snd_una advances to frto_highmark, it is likely that the hole was
>> filled by the retransimitted packet, which means the original packet
>> was likely to have been lost.
>> So, we should enter loss state.
>>
>
> I do not agree with it, if snd_una advanced to frto_highmark, which m=
eans
> peer acks whole window of data instead of just one segment, and
> we can not make sure that reason of peer sends ack is whether it rece=
ived
> original segment or retransmitted segment.
>
> Even, the reason is latter, it also means the netowrk already is
> recovered from temporarily congestion or disordered state, so we also=
 should
> not enter loss state.
>
> Thanks
>
> Yu
>

If it is for the first reason, then the receiver should not ack the
whole rtt of packets with just one ack. Instead, it should send ack
once every second packet. So, we can almost be sure that the original
packet was lost.

As for the second question. I think since the loss is proven and was
actually detected because of the RTO timer, we should enter loss
state.

Thanks.
