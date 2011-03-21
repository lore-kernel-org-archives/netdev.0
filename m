From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: add Faraday FTGMAC100 Gigabit Ethernet driver
Date: Mon, 21 Mar 2011 09:19:29 +0100
Message-ID: <1300695569.2831.535.camel@edumazet-laptop>
References: <1299744517-1896-1-git-send-email-ratbert.chuang@gmail.com>
	 <1300355238-1619-1-git-send-email-ratbert.chuang@gmail.com>
	 <1300357457.3133.92.camel@edumazet-laptop>
	 <AANLkTino6LzGTZF4fNSkV9pbAfnmAc8wJjk0L8HfHDiJ@mail.gmail.com>
	 <1300361405.3133.175.camel@edumazet-laptop>
	 <AANLkTinibrF_bJBbYwCSnGv1iD_9Dn7uBn2cqgcTrKHi@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ratbert@faraday-tech.com
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinibrF_bJBbYwCSnGv1iD_9Dn7uBn2cqgcTrKHi@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 21 mars 2011 =C3=A0 15:54 +0800, Po-Yu Chuang a =C3=A9crit :
> It seems to work fine so far at least the driver is not broken, but I=
 did not
> see much difference in performance though. How do I know if GRO is
> working indeed?

maybe you receive one interrupt per incoming frame, and your cpu is fas=
t
enough to handle the load.

tcpdump should show big incoming TCP frames (multi segment)

(GRO only helps TCP receivers)

Example here :


09:16:32.372949 IP 192.168.20.110.55446 > 192.168.20.108.ssh: .
2372863:2374311(1448) ack 3136 win 73 <nop,nop,timestamp 317934201
257881345>

09:16:32.372975 IP 192.168.20.110.55446 > 192.168.20.108.ssh: .
2374311:2377207(2896) ack 3136 win 73 <nop,nop,timestamp 317934201
257881345>


Here, you can see GRO work, since 2nd "frame" is the result of two MTU
sized frames.=20
