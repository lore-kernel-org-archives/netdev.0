From: =?UTF-8?Q?=E3=83=84_Leandro_Melo_de_Sales?= <leandroal@gmail.com>
Subject: Re: TCP packet size and delivery packet decisions
Date: Tue, 7 Sep 2010 03:02:22 -0300
Message-ID: <AANLkTi=x4+YqyuOvpnUXd2PjMHifMPXEgEA=0=+wfPk7@mail.gmail.com>
References: <AANLkTikMPENe011GxK15TNTXwdckZSSYfb=3pdDwfUeG@mail.gmail.com>
 <20100906.221644.123986391.davem@davemloft.net> <AANLkTik75BGz=csDKVRk+Ni9__MqXMpHeqi_sHniu09A@mail.gmail.com>
 <20100906.223010.173858342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42920 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711Ab0IGGCn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 02:02:43 -0400
Received: by fxm13 with SMTP id 13so2804558fxm.19
        for <netdev@vger.kernel.org>; Mon, 06 Sep 2010 23:02:42 -0700 (PDT)
In-Reply-To: <20100906.223010.173858342.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/9/7 David Miller <davem@davemloft.net>:
> From: =E3=83=84 Leandro Melo de Sales <leandroal@gmail.com>
> Date: Tue, 7 Sep 2010 02:21:42 -0300
>
>> This is a embedded system implemented in a proprietary hardware that=
 I
>> can send TCP commands to turn on/off relays. It will be very difficu=
lt
>> to find the reason for this behaviour. Since it needs to receive ver=
y
>> small data, probably it is not necessary to scaling window.
>
> The small 78 byte window is why the sending system is splitting up th=
e
> writes into smaller pieces.
>
> I presume that the system advertises exactly a 78 byte window because
> this is how large the commands are. =C2=A0But this is an extremely fo=
olish
> and baroque thing to do, and it's why you are having problems.
>

David,
   Yes, 78 bytes is the size of each command. I have concluded the
same as you. In this case, to deal with this type of situation, how
about changing TCP implementation on Linux to send the whole packet
when it is too small such in this case or when TCP notice that there
is no change in the advertised rcwd or when advertised win is equal to
advertised MSS, since the receiver is saying "I can receive packets in
the same size of my cwd"?

  I'm sorry if I'm suggesting something that does not make sense, but
since receiver advertises that are able to receive packets in that
size which is equal to the congwin size, splitting the packet in this
case only [unnecessarily] increased the flow completion time or avoid
data to be delivered to the application as soon as possible since it
arrived splitted. As we could notice from the tcpdump report, TCP
implementation under Linux does not wait for any ACK of the first 48
bytes sent out, it just sent the other 30 bytes in a consecutive
delivery, which is the same as sending 78 bytes at once, since no
decision is taken to send or not the other last 30 bytes.

   Regardless this discussion, can you at least suggest any workaround
that I can do in the application layer to make TCP send the whole
packet at once? As I said, I tried to use TCP_CORK suggested by
Arnaldo (acme), but it does not work for me in this case.

Leandro.
