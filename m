From: Antonio Gallo <agx@linux.it>
Subject: [Bug] PPPoATM or ATM module problem with ADSL PCI Cards
Date: Wed, 5 Mar 2003 15:27:47 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030305142747.GA17315@ax-agx.axnet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mitch@sfgoth.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I'm not sure if is a real bug or something wrong but after 3 weeks
of tests i'm thinking is something inside the kernel (pppoatm.o)
or the ATM layer in general, and so some friend at @linux.it
suggest me to contact directly the mantainers instead of writing
to the kernel ML.


This is the situation:

LAN <=== ethernet ===> Zyxel Router <=== PPPoA ===> Provider

This works!

I remove the phone cable from the router and put it into our Linux Box

Linux <=== PPPoA ===> Provider

I've used 2 different kind of cards:
1. BeWan PCI ADSL ST (ATM driver + pppd with the atm plugin)
2. Pulsar ADSL (provide /dev/ttyG0 so i just use normal ppp )

Boths card can detect the line (Link Up), i can also see the "link"
LED to become "on".

Where i run the PPP to connect to the provider i can see the "Tx"
LED working but the "Rx" LED not. Confirmation of this is done
through "ifconfig" or "cat /proc/net/atm/UNICORN:0" that showme
a positive number for Tx and Error number for Rx.

I contacted the provider of the line and it told me the right
parameter of the line, that i was already know.
	Provider: Elitel (via Telecom Italia) - Italy
	Line: DTM
	Protocol VCMUX, RFC2364, PPPoA
	VPI.VCI: 8.35
	Bandwidth: 128 up / 640 down
	User access: username+password (PPP CHAP/PAP)
	Ip address: Dynamically assigned

I stayed with them 1 hour on the phone. Infact they was able to
see that i am transmitting "atm cells" but that cells contains
invalid data and so they dropped them.

This is the reason why i never see Rx packet?

So whereis the problem? Kernel or ppp pluging sending wrong information?
If the problem was the card it will be strange to have the same problem
on the same card (different drivers, different architectures, different
chipset etc.).

So is my machine really sending wrong atm cells?

Debugging of the "Bewan" driver showed this:

Mar  5 11:06:53 ax-dummy kernel: unicorn_atmdrv.c : unicorn_atm_open: 
Mar  5 11:06:53 ax-dummy kernel: unicorn_atm: ESI=00:9f:c8:f1:f7:58
Mar  5 11:06:53 ax-dummy kernel: unicorn_atm: upstream_rate=639 Kbits/s,downstream_rate=6143 Kbits/s
Mar  5 11:06:53 ax-dummy kernel: unicorn_atmdrv.c : get_link_rate: link_rate=1507 cells/sec
Mar  5 11:06:53 ax-dummy kernel: unicorn_atmdrv.c : aal5_decode: skb to short,skb->len=48,pdu_length=27264
Mar  5 11:06:53 ax-dummy kernel: unicorn_atmdrv.c : rcv_poll: wrong VPI.VCI 15.16
Mar  5 11:06:53 ax-dummy kernel: unicorn_atmdrv.c : rcv_poll: wrong VPI.VCI 15.16
Mar  5 11:06:53 ax-dummy kernel: unicorn_atmdrv.c : aal5_decode: skb to short,skb->len=48,pdu_length=27264

i am also waiting an answer from the support of both ADSL cards.

I hope you can give some indication about why i'm sending wrong cells
and how to check which/where is the real problem.

Ops, i forget to mention that i tested with both 2.4.20 and 2.4.18 kernels.

Thank you in advance,
	Antonio Gallo
	www.badpenguin.org


p.s.
	i'm really lost :-(
