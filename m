From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH iproute2] tc_codel: Controlled Delay AQM
Date: Tue, 22 May 2012 16:59:48 -0700
Message-ID: <CAA93jw5oOz38UHsp2UODJcbn9uDz34RfPSNCE-qE-7BKoshLtA@mail.gmail.com>
References: <1336717355.31653.130.camel@edumazet-glaptop>
	<20120522141610.601f68ed@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Dave Taht <dave.taht@bufferbloat.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:55617 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932839Ab2EVX7u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 19:59:50 -0400
Received: by lbbgm6 with SMTP id gm6so4680863lbb.19
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 16:59:48 -0700 (PDT)
In-Reply-To: <20120522141610.601f68ed@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I promised eric I'd write the two man pages.

I also promised myself a vacation. The last year has been a long hard
road. If someone
hasn't got to writing the man pages by the time I get back from lupin,
I'll write it.

On Tue, May 22, 2012 at 2:16 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Fri, 11 May 2012 08:22:35 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> An implementation of CoDel AQM, from Kathleen Nichols and Van Jacobs=
on.
>>
>> http://queue.acm.org/detail.cfm?id=3D2209336
>>
>> This AQM main input is no longer queue size in bytes or packets, but=
 the
>> delay packets stay in (FIFO) queue.
>>
>> As we don't have infinite memory, we still can drop packets in enque=
ue()
>> in case of massive load, but mean of CoDel is to drop packets in
>> dequeue(), using a control law based on two simple parameters :
>>
>> target : target sojourn time (default 5ms)
>> interval : width of moving time window (default 100ms)
>>
>> Selected packets are dropped, unless ECN is enabled and packets can =
get
>> ECN mark instead.
>>
>> Usage: tc qdisc ... codel [ limit PACKETS ] [ target TIME ]
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 [ interval TIME =
] [ ecn ]
>>
>> qdisc codel 10: parent 1:1 limit 2000p target 3.0ms interval 60.0ms =
ecn
>> =A0Sent 13347099587 bytes 8815805 pkt (dropped 0, overlimits 0 reque=
ues 0)
>> =A0rate 202365Kbit 16708pps backlog 113550b 75p requeues 0
>> =A0 count 116 lastcount 98 ldelay 4.3ms dropping drop_next 816us
>> =A0 maxpacket 1514 ecn_mark 84399 drop_overlimit 0
>>
>> CoDel must be seen as a base module, and should be used keeping in m=
ind
>> there is still a FIFO queue. So a typical setup will probably need a
>> hierarchy of several qdiscs and packet classifiers to be able to mee=
t
>> whatever constraints a user might have.
>>
>> One possible example would be to use fq_codel, which combines Fair
>> Queueing and CoDel, in replacement of sfq / sfq_red.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Dave Taht <dave.taht@bufferbloat.net>
>> ---
>> Notes :
>> 1) : Dave Taht will send a nice man-page for this stuff.
>> 2) : the TCA_NETEM_ECN bit is because of include/linux/pkt_sched.h s=
ync
>> with net-next
>> =A0 =A0 =A0(I'll send a separate patch for netem)
>>
>
> Applied. Used 3.5 sanitized header (not the one in your patch),
> and fixed whitespace error.
>
>
> Ok, where's the man page :-)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://www.bufferbloat.net
