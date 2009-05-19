From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 19 May 2009 11:55:43 +0100
Message-ID: <298f5c050905190355r1594b51ex7a7f3d452cc9c059@mail.gmail.com>
References: <20090517201528.GA8552@ami.dom.local>
	 <20090518065629.GA6006@ff.dom.local>
	 <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com>
	 <20090518175352.GB2755@ami.dom.local>
	 <298f5c050905181123o55c35e74n24cd4ee2c07d8fca@mail.gmail.com>
	 <20090518183221.GC2755@ami.dom.local>
	 <298f5c050905181156w2254fcb4p889d67e26fad6e6@mail.gmail.com>
	 <20090518190541.GA3047@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:1828 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbZESKzo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 06:55:44 -0400
Received: by yx-out-2324.google.com with SMTP id 3so2347354yxj.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 03:55:45 -0700 (PDT)
In-Reply-To: <20090518190541.GA3047@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doesn't seem to make any diference seting HTB_HYSTERESIS to 0. Here're
the values using #define HTB_HYSTERESIS 0

800 bytes:
class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
70901b/8 mpu 0b overhead 0b level 0
 Sent 9773257752 bytes 12277962 pkt (dropped 6292541, overlimits 0 requ=
eues 0)
 rate 621796Kbit 97644pps backlog 0b 127p requeues 0
 lended: 12277835 borrowed: 0 giants: 0
 tokens: -7 ctokens: -7

850 bytes:
class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
70901b/8 mpu 0b overhead 0b level 0
 Sent 18225005732 bytes 22409017 pkt (dropped 11937269, overlimits 0 re=
queues 0)
 rate 600890Kbit 88796pps backlog 0b 43p requeues 0
 lended: 22408974 borrowed: 0 giants: 0
 tokens: -2 ctokens: -2

900 bytes:
class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
70901b/8 mpu 0b overhead 0b level 0
 Sent 29790867368 bytes 35400708 pkt (dropped 18399726, overlimits 0 re=
queues 0)
 rate 636361Kbit 88779pps backlog 0b 127p requeues 0
 lended: 35400581 borrowed: 0 giants: 0
 tokens: -2 ctokens: -2


  Antonio Almeida



On Mon, May 18, 2009 at 8:05 PM, Jarek Poplawski <jarkao2@gmail.com> wr=
ote:
> On Mon, May 18, 2009 at 07:56:12PM +0100, Antonio Almeida wrote:
>> Precise measurements:
>>
>> 800 bytes:
>> class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
>> 555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
>> 70901b/8 mpu 0b overhead 0b level 0
>> =A0Sent 46793626324 bytes 57771194 pkt (dropped 29920019, overlimits=
 0 requeues 0)
>> =A0rate 621714Kbit 97631pps backlog 0b 126p requeues 0
>> =A0lended: 57771068 borrowed: 0 giants: 0
>> =A0tokens: -8 ctokens: -8
>>
>>
>> 850 bytes:
>> class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
>> 555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
>> 70901b/8 mpu 0b overhead 0b level 0
>> =A0Sent 63422144616 bytes 77714246 pkt (dropped 41012275, overlimits=
 0 requeues 0)
>> =A0rate 600699Kbit 88756pps backlog 0b 127p requeues 0
>> =A0lended: 77714119 borrowed: 0 giants: 0
>> =A0tokens: -11 ctokens: -11
>>
>>
>> 900 bytes:
>> class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
>> 555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
>> 70901b/8 mpu 0b overhead 0b level 0
>> =A0Sent 76868403562 bytes 92835297 pkt (dropped 48565133, overlimits=
 0 requeues 0)
>> =A0rate 636195Kbit 88755pps backlog 0b 126p requeues 0
>> =A0lended: 92835171 borrowed: 0 giants: 0
>> =A0tokens: -7 ctokens: -7
>>
>>
>> If you need more values you're free to ask.
>
> Since you're so kind... :-) There is a line in net/sched/sch_htb.c:
>
> #define HTB_HYSTERESIS 1 =A0 =A0 =A0 =A0/* whether to use mode hyster=
esis for speedup */
>
> Could you change 1 to 0, and repeat these tests above after recompili=
ng?
>
> More thanks,
> Jarek P.
>
