From: Alberto Bertogli <albertogli@telpin.com.ar>
Subject: Frozen machine with adding a tc filter
Date: Mon, 22 Jul 2002 00:49:19 -0300
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020722034919.GH685@telpin.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: lartc@mailman.ds9a.nl
Content-Disposition: inline
List-Id: netdev.vger.kernel.org


Hi!

This is a (really early) bug report on one i just caught when setting a
filter for traffic control.

It makes the machine to frozen solid, without even an oops. Keyboard is not
responsive (neither sysrq nor the num/caps/screen lock leds), everything
seems quite dead.

It's fully reproducible, i tried both 2.4.13 and 2.4.19-rc3 (the last one
with htb patches, but i don't think it's related).

The machine is an iPII with 256Mb RAM, it has been working well for about a
year and a half.


Basically a main cbq class with two (also cbq) leaves:
tc qdisc add dev eth1 root handle 20:0 cbq bandwidth 100Mbit avpkt 1000
tc class add dev eth1 parent 20:0 classid 20:1 $EST cbq bandwidth 100Mbit \
	rate 2800Kbit bounded isolated $CBQ_PARAMS

($EST is empty and $CBQ_PARAMS is "allot 1514 avpkt 1000")

Both leaves are basically the same, just a cbq class with parent 20:1 and
then sfq attached as qdisc; really simple. I have another set pretty much
like this one, only with one leave, on eth0.

The command which frozes the machine is
tc filter add dev eth1 parent 20:0 protocol ip handle 5 fw classid 20:0

I know it's weird, but anyway i don't think that a lockup is the error the
user deserves =)

Setting classid 20:X (X != 0) works as expected.

As this is quite early (just hit it) i don't know if i can reproduce it
using another scenario.

Tomorrow i'll try to dig into it on a testing machine and i'll post the
results.


Thanks,
		Alberto
