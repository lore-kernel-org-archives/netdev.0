From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: DHCP via bridge in case of IPv4
Date: Sat, 9 Jul 2016 08:37:55 +0000
Message-ID: <1468053400.5007.5.camel@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-7"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"lede-dev@lists.infradead.org" <lede-dev@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-snps-arc@lists.infradead.org"
	<linux-snps-arc@lists.infradead.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Content-ID: <AFD5EA111CA2634B80121D82959929E1@internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I was playing with quite simple bridged setup on different boards with
very recent kernels (4.6.3 as of this writing) and found one interesting
behavior that I cannot yet understand and googling din't help here as well.

My setup is pretty simple:
-------------+AKAAoACgAKAAoACgAKA-------------------+AKAAoACgAKAAoACgAKA--------------------------
+AHw- HOST+AKAAoACgAKAAoACgAHwAoACgAKAAoACgAKAAoAB8- +ACI-Dumb AP+ACIAoACgAKAAoACgAKAAfACgAKAAoACgAKAAoACgAHw- Wireless client+AKAAoACgAKAAoACgAKAAfA-
+AHw- with DHCP +AHwAPA------+AD4-(eth0)+AKAAoACgAKAAoA-(wlan0)+ADw------+AD4AfA- attempting to+AKAAoACgAKAAoACgAKAAoACgAHw-
+AHw- server+AKAAoACgAKAAfACgAKAAoACgAKAAoACgAHwAoACgAKAAoABc- br0 /+AKAAoACgAKAAoAB8AKAAoACgAKAAoACgAKAAfA- get settings via DHCP +AHw-
-------------+AKAAoACgAKAAoACgAKA-------------------+AKAAoACgAKAAoACgAKA--------------------------

+ACo- HOST is my laptop with DHCP server that works for sure.
+ACo- +ACI-Dumb AP+ACI- is a separate board (I tried ARM-based Wandboard and ARC-based
+AKA- AXS10x boards but results are exactly the same) with wired (eth0) and wireless
+AKA- (wlan0) network controllers bridged together (br0). That +ACI-br0+ACI- bridge flawlessly
+AKA- gets its settings from DHCP server on host.
+ACo- Wireless client could be either a smatrphone or another laptop etc but
+AKA- what's important it should be configured to get network settings by DHCP as well.

So what happens +ACI-br0+ACI- always gets network settings from DHCP server on HOST.
That's fine. But wireless client only reliably gets settings from DHCP server
if IPv6 is enabled on +ACI-Dumb AP+ACI- board. If IPv6 is disabled I may see that
wireless client sends +ACI-DHCP Discover+ACI- then server replies with +ACI-DHCP Offer+ACI- but
that offer never reaches wireless client.

Well actually sometimes very-very rarely that offer may reach wireless client but
I cannot understand how to reproduce it reliably.

Still looks like enabling of IPv6 fixes that issue.

So my question here is: why I see that difference with IPv4 vs IPv6?

One sidenote:
+AKA- Somehow I figured out that in case of IPv4 so-called routing
+AKA- cache is absent (it was removed in Linux kernel 3.6) while with IPv6 it
+AKA- still exist. And assuming my hardware is sane and no data gets lost I may
+AKA- think that it's really a routing problem and missing routing cache might
+AKA- be an answer. Still being a noob in networking stuff I'd like to get a bit
+AKA- better explanation of things I see.

All thoughts and comments are more than welcome.

Regards,
Alexey
