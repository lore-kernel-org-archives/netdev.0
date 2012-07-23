From: Michael Leun <lkml20120218@newton.leun.net>
Subject: Re: [3.5 regression / mcs7830 / bisected] bridge constantly
 toggeling between disabled and forwarding
Date: Tue, 24 Jul 2012 01:36:34 +0200
Message-ID: <20120724013634.11bf1360@xenia.leun.net>
References: <20120723091504.2d035d28@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120723091504.2d035d28@xenia.leun.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Jul 2012 09:15:04 +0200
Michael Leun <lkml20120218@newton.leun.net> wrote:

[see issue description below]

Bisecting yielded

b1ff4f96fd1c63890d78d8939c6e0f2b44ce3113 is the first bad commit
commit b1ff4f96fd1c63890d78d8939c6e0f2b44ce3113
Author: Ondrej Zary <linux@rainbow-software.org>
Date:   Fri Jun 1 10:29:08 2012 +0000

    mcs7830: Implement link state detection

    Add .status callback that detects link state changes.
    Tested with MCS7832CV-AA chip (9710:7830, identified as rev.C by the driver).
    Fixes https://bugzilla.kernel.org/show_bug.cgi?id=28532

    Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 5480780cb5e75c57122a621fc3bab0108c16be27 d97efd9cc0a465dff76bcd3a3c547f718f2a5345 M    drivers


Reverting that from 3.5 makes the issue go away.

> Hi,
> 
> when I use my usb ethernet adapter
> 
> # > lsusb
> [...]
> Bus 002 Device 009: ID 9710:7830 MosChip Semiconductor MCS7830 10/100 Mbps Ethernet adapter
> [...]
> 
> as port of an bridge
> 
> > # brctl addbr br0
> > # brctl addif br0 eth0
> > # brctl addif br0 ue5
> > # ifconfig ue5 up
> > # ifconfig br0 up
> 
> (Also does happen when eth0 is not part of the bridge, but the logs I
> had available were from that situation...)
> 
> I constantly get messages showing the interface toggeling between
> disabled and forwarding state:
> 
> Jul 23 07:40:50 elektra kernel: [ 1539.497337] br0: port 2(ue5) entered disabled state
> Jul 23 07:40:50 elektra kernel: [ 1539.554992] br0: port 2(ue5) entered forwarding state
> Jul 23 07:40:50 elektra kernel: [ 1539.555005] br0: port 2(ue5) entered forwarding state
> Jul 23 07:40:51 elektra kernel: [ 1540.496242] br0: port 2(ue5) entered disabled state
> Jul 23 07:40:51 elektra kernel: [ 1540.552534] br0: port 2(ue5) entered forwarding state
> Jul 23 07:40:51 elektra kernel: [ 1540.552548] br0: port 2(ue5) entered forwarding state
> Jul 23 07:40:52 elektra kernel: [ 1541.550413] br0: port 2(ue5) entered forwarding state
> Jul 23 07:40:53 elektra kernel: [ 1542.529672] br0: port 2(ue5) entered disabled state
> Jul 23 07:40:53 elektra kernel: [ 1542.587162] br0: port 2(ue5) entered forwarding state
> Jul 23 07:40:53 elektra kernel: [ 1542.587175] br0: port 2(ue5) entered forwarding state
> Jul 23 07:40:54 elektra kernel: [ 1543.585309] br0: port 2(ue5) entered forwarding state
> Jul 23 07:41:00 elektra kernel: [ 1549.360600] br0: port 2(ue5) entered disabled state
> Jul 23 07:41:00 elektra kernel: [ 1549.442998] br0: port 2(ue5) entered forwarding state
> Jul 23 07:41:00 elektra kernel: [ 1549.443011] br0: port 2(ue5) entered forwarding state
> Jul 23 07:41:01 elektra kernel: [ 1550.357686] br0: port 2(ue5) entered disabled state
> Jul 23 07:41:01 elektra kernel: [ 1550.408208] br0: port 2(ue5) entered forwarding state
> Jul 23 07:41:01 elektra kernel: [ 1550.408222] br0: port 2(ue5) entered forwarding state
> Jul 23 07:41:02 elektra kernel: [ 1551.407656] br0: port 2(ue5) entered forwarding state
> Jul 23 07:41:03 elektra kernel: [ 1552.401578] br0: port 2(ue5) entered disabled state
> Jul 23 07:41:03 elektra kernel: [ 1552.474773] br0: port 2(ue5) entered forwarding state
> Jul 23 07:41:03 elektra kernel: [ 1552.474786] br0: port 2(ue5) entered forwarding state
> Jul 23 07:41:04 elektra kernel: [ 1553.472487] br0: port 2(ue5) entered forwarding state
> Jul 23 07:41:05 elektra kernel: [ 1554.356138] br0: port 2(ue5) entered disabled state
> [...]
> 
> This does (in the same situation, nothing else than the kernel changed)
> not happen with 3.4.5.
> 
> Does anybody have an idea what the issue might be or do I need to bisect?


-- 
MfG,

Michael Leun
