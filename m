From: "Larry Sendlosky" <Larry.Sendlosky@storigen.com>
Subject: via-rhine "reset did not complete" errors
Date: Mon, 28 Oct 2002 10:45:08 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <7BFCE5F1EF28D64198522688F5449D5A03C079@xchangeserver2.storigen.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <rl@hellgate.ch>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

We're using VIA EPIA mini-ITX with 800Mhz C3 and the
VT6103 PHY. (via-rhine driver says VT6102). We have made sure
power supply is "big enough". Our kernel is 2.4.18 with
via-rhine.c patches to fix TX timeout.

Our TX timeout issues seem to have gone away with the recent
patches. However we are still plagued with the "reset did not
complete in 10ms" errors. Once it this state, a warm restart of
the system is necessary (and we have seen this problem at
boot time, which is more confusing).

Anyway, we can make this problem occur easily by doing
'ifconfig down eth0' followed by 'ifconfig up eth0'. The
error happens on the 'open' of the device. However, when
we do this with 'no link' (cable not plugged in), the
problem does not happen. It only seems to happen when
there is activity on the wire and plugged in. When the
reset does not happen, the CR0/CR1 state after the reset
is always 0x8008 now matter what the current state of
those regs going into the reset.

So it appears the problem is actually in the 'close' when
possibly in the process of receiving a packet. Especially
given that via_rhine_close puts the device in loopback mode
to void hardware races. Does via_rhine_close need to be
a little smarter/paranoid? :))  Besides register definitions,
the docs are pretty useless.

Are there hardware issues that are still not fixed? eg.
a reset does not reset the chip regardless of state.

Any help or ideas would be appreciated.

thanks

larry
