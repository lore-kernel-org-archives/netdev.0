From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: ethernet/b44: Bug in b44.c:v0.93 (Mar, 2004) ethernet driver in 2.6.6
Date: Fri, 14 May 2004 16:02:06 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040514130206.GA9583@ee.oulu.fi>
References: <lzekpnlxwl.fsf@nimiumvax.nimium.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-kernel@vger.kernel.org, pavel@ucw.cz, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Miroslav Zubcic <mvz@nimium.com>
Content-Disposition: inline
In-Reply-To: <lzekpnlxwl.fsf@nimiumvax.nimium.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 14, 2004 at 01:17:46AM +0200, Miroslav Zubcic wrote:
> After reading Changelog for 2.6.6, I have seen b44 driver was updated,
> and it should support new HP/compaq laptops now. I tried 2.6.6 kernel,
> but I have a problem: b44 module does not work(TM).
> 
> modprobe b44 and `ip link set dev eth0 up' gives this in dmesg:
> 
> --------------
> b44.c:v0.93 (Mar, 2004)
> PCI: Guessed IRQ 11 for device 0000:01:0e.0
> divert: allocating divert_blk for eth0
> eth0: Broadcom 4400 10/100BaseT Ethernet 00:08:02:e2:2d:ba
> b44: eth0: BUG!  Timeout waiting for bit 80000000 of register 428 to clear.
> b44: eth0: BUG!  Timeout waiting for bit 80000000 of register 428 to clear.
> b44: eth0: BUG!  Timeout waiting for bit 80000000 of register 428 to clear.
> Host pinging on network timeouts with icmp destination host
> Output from "/sbin/ip addr list" looks perfectly normal BTW. :-\
> 
> It works OK with 2.4.21 kernel and bcm4401 driver from broadcom
> www site. It does not work with 2.6.5 in any way.
Hi

This bug has appeared in the past too 
(eg. http://bugzilla.kernel.org/show_bug.cgi?id=2030 ), for me it triggers
only when using a broadcom driver and then trying b44 without a cold reset 
or using the workaround in the bug report that runs a part of bcm4400 
initialization process.

Another known bug has been seen when using 4G/4G split and having 
> 1G of memory (https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=118165
, bugzilla is broken currently tho), but if you have more than a gig
mem=900M or whatnot is worth a try in any case.

Since it works perfectly (tm) on my hardware assuming I never load bcm4400 I
haven't put that much effort in tracking the reason what magic
"break b44 bit" bit broadcom drivers  set. I suppose I could give it a few 
hours this weekend tho... On some machines (I think dells) the timeout
waiting for 428 appears to happen even without bcm4400 getting loaded
so finally tracking this down would be really nice...
