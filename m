From: Asim Shankar <asimshankar@gmail.com>
Subject: Re: netif_rx_schedule_prep() returning false?
Date: Wed, 2 Feb 2005 14:41:59 -0600
Message-ID: <7bca1cb5050202124149bd7f04@mail.gmail.com>
References: <7bca1cb5050202100475279073@mail.gmail.com>
	 <1107371791.3366.126.camel@sfeldma-mobl.dsl-verizon.net>
Reply-To: Asim Shankar <asimshankar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: sfeldma@pobox.com
In-Reply-To: <1107371791.3366.126.camel@sfeldma-mobl.dsl-verizon.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I'm running the same setup with delays turned off and I'm not seeing
> what you're seeing.  What e1000 controller are you using?  Send lspci
> -n.

lspci -n:
00:00.0 Class 0600: 8086:7190 (rev 03)
00:01.0 Class 0604: 8086:7191 (rev 03)
00:07.0 Class 0601: 8086:7110 (rev 02)
00:07.1 Class 0101: 8086:7111 (rev 01)
00:07.2 Class 0c03: 8086:7112 (rev 01)
00:07.3 Class 0680: 8086:7113 (rev 02)
00:10.0 Class 0200: 8086:1076
00:11.0 Class 0200: 10b7:9055
00:13.0 Class 0604: 1011:0024 (rev 03)
01:00.0 Class 0300: 10de:0028 (rev 11)

This happens when a more "powerful" machine sends to a less powerful
one and not the reverse. My setup is so:
Machine A: Dual Xeon 2.8Ghz, 1GB RAM Dell PowerEdge 1800
Machine B: Dual P-III 500Mhz, 512MB RAM, old Dell Precision 410

I'm using netperf, so B is running a "netserver" and the netperf
client application is started on A. "lspci" shown above is from "B".

When reversed, B sending TO A, then machine A doesn't complain at all.
Machine A also has the same card: Intel PRO/1000 MT Desktop Adapter -
Class 0200: 8086:1076.

Thanks,
Regards,

-- Asim

P.S. Changes to e1000_intr() in order to check this:
o Added "int rx_sched = test_bit(__LINK_STATE_RX_SCHED, &netdev->state);
o Later, added an "else" to the "if
(likely(netif_rx_schedule_prep(nedev))" block where I do a printk()
