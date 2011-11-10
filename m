From: Denys Fedoryshchenko <denys-ArQk2d8GGkZT5gTzvV8LJA@public.gmane.org>
Subject: Re: creating netdev queues on the =?UTF-8?Q?fly=3F?=
Date: Thu, 10 Nov 2011 16:55:54 +0200
Message-ID: <7be02f26a67fac4c7448a74f1f17aa01@visp.net.lb>
References: <1320933501.3967.68.camel@jlt3.sipsolutions.net>
 <CAGXE3d-_RFgW_zwfX2vTBe1psXmgoBFO5pd5cAgtYo=Jwpddhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGXE3d-_RFgW_zwfX2vTBe1psXmgoBFO5pd5cAgtYo=Jwpddhw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 On Thu, 10 Nov 2011 15:40:01 +0100, Helmut Schaa wrote:
>>
>> I think this might also make implementing reservation (tspec) 
>> easier.
>> Not sure if anyone wants/needs that though.
>
> Wouldn't it be possible to implement something like this as a qdisc 
> on top of
> mq that makes use of the current tx rate per station to distribute
> the airtime
> equitably?
>
> Of course this would require the qdisc to know the tx rate a priori 
> but for
> mac80211 drivers we could just use last_tx_rate as an estimate ...
>
> Helmut
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

 Maybe someone will make something like "tfifo" in future :)
 And when clients are connected, each have his own queue.

 then, for example qdisc add dev wlan0 parent 1:10 handle 10 tfifo limit 
 100ms
 If packet are older than 100ms will be dropped, or new packets are not 
 added, if
 there is packet older than 100ms are not sent yet.

 I am not sure that bandwidth will be distributed fairly, it is 
 different question,
 probably each queue should have some "limited chunk of time" to send 
 data.
 And again, 802.11a/b/g at least are half-duplex and CSMA, and without 
 polling/TDMA or CTS/RTS tricks
 it will be complicated to give guaranteed chunks of time.

 P.S. That's just a dream :)

 ---
 Network engineer
 Denys Fedoryshchenko

 P.O.Box 41553 Jeddah 21531
 Tel:   920023422
 Fax:  +966 26501784
 E-Mail: denys-ArQk2d8GGkZT5gTzvV8LJA@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
