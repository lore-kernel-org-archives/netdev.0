From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP packet size and delivery packet decisions
Date: Tue, 07 Sep 2010 09:32:41 +0200
Message-ID: <1283844761.2338.32.camel@edumazet-laptop>
References: <AANLkTikMPENe011GxK15TNTXwdckZSSYfb=3pdDwfUeG@mail.gmail.com>
	 <20100906.221644.123986391.davem@davemloft.net>
	 <AANLkTik75BGz=csDKVRk+Ni9__MqXMpHeqi_sHniu09A@mail.gmail.com>
	 <20100906.223010.173858342.davem@davemloft.net>
	 <AANLkTi=x4+YqyuOvpnUXd2PjMHifMPXEgEA=0=+wfPk7@mail.gmail.com>
	 <1283839769.2585.572.camel@edumazet-laptop>
	 <AANLkTi=haxW2SVqes-7HYtQjSx052WUNNWV-BOaqQpHY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Thiago Luiz <thiagolcpeixoto@gmail.com>
To: =?UTF-8?Q?=E3=83=84?= Leandro Melo de Sales <leandroal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57200 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755370Ab0IGHcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 03:32:45 -0400
Received: by fxm13 with SMTP id 13so2823770fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 00:32:44 -0700 (PDT)
In-Reply-To: <AANLkTi=haxW2SVqes-7HYtQjSx052WUNNWV-BOaqQpHY@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 04:16 -0300, =E3=83=84 Leandro Melo d=
e Sales a
=C3=A9crit :

> My short answer is: this is not a critical problem for me, at all. I
> just thought that this could be easily fixed by finding the source of
> the problem, as David and I shared it is due to small and fixed cwd
> advertised by the receiver.
>=20
> But...  This just make me think about why it works under windows, but
> not under linux. When I begin to think about the relation between Win
> and MSS, in my point of view it is feasible to think like I said: if
> the receiver is telling me that it is able to receive a packet that i=
s
> in the same size of the cwd and cwd is sufficiently small in respect
> to congestion control mechanism and MTU size, why postpone the flow
> completion time if I can do this at once, ... avoid make two
> consecutive TCP-PSH without any sending decision between them? For ou=
r
> discussion MSS =3D=3D Win, while they are very small if compared to M=
TU,
> almost 20 times, at least in ethernet. I know that "very", "small",
> "big", "tall", "short" etc are very vague works, and everything will
> depend on the point of view, but maybe we can consider Win a very
> small size (at lease when it is equal to MSS) when TCP is in the Slow
> Start phase until ssthresh, don't know...
>=20
>     From one perspective I agree with David that the receiver device
> of my case provided a kind of foolish and/or baroque implementation,
> but in another perspective they where very smart to announce MSS =3D=3D
> cwd, this way they avoiding sender to send more than it (receiver) ca=
n
> handle, does not use too much resource since it does not increase the
> cwd, in addition to telling to the sender: "send me your complete
> 'sk_write_queue' at once (talking about Linux TCP implementation)".
> But Linux did not, instead it sent two consecutive packets without an=
y
> decision taken between them, why? In this case, how much resource we
> spend when we allocate a new packet and add it in the double-linked
> queue? how much computation we wasting when we have to process one
> more packet (in this case for each tcp.send())? Well, if this is not
> the case here or if wasting resources is computational cheaper than
> make some checks and send the packet at once, let's try another
> approach...
>=20
>    Well, I don't know if what I mentioned above are real arguments to
> promote a change in the TCP implementation, just want to solve my
> problem, at the same time I have decided to share with you guys my
> problem, since maybe it can be a problem faced by someone else when
> using Linux, or already occurred in the past.
>=20
>    Finally, one other (at least for my project) consideration is that
> I wouldn't like to deploy my application only under windows (since
> there my app works) and tell to my customer: well, we have done a
> multi-platform solution, but due to **this** issue we won't be able t=
o
> deploy the system under linux because it simply does not work (at
> least considering all tests using alternatives and workaround that I
> have mentioned in my previous e-mail).


Really this has nothing to do with congestion.

We send _one_ packet, and this packet has not the optimum size.

This can be fixed, with a 100% probability :)

Quite frankly, if your application depends on _one_ packet being sent
instead of two, you can do even better under linux, avoiding the third
packet (pure ACK) of the tcp session :=3D)

192.168.0.34    192.168.0.70    [SYN] Seq=3D0 Win=3D5840 Len=3D0 MSS=3D=
1460
192.168.0.70    192.168.0.34    [SYN, ACK] Seq=3D0 Ack=3D1 Win=3D78 Len=
=3D0 MSS=3D78
192.168.0.34    192.168.0.70    [PSH, ACK] Seq=3D1 Ack=3D1 Win=3D5840 L=
en=3D78

Nice isnt it ?

BTW, what is the version of linux kernel you use ?



