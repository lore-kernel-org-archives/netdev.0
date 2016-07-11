From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [LEDE-DEV] DHCP via bridge in case of IPv4
Date: Mon, 11 Jul 2016 06:15:58 +0000
Message-ID: <1468217682.5588.4.camel@synopsys.com>
References: <1468053400.5007.5.camel@synopsys.com>
	 <CAKNoO9oK-_sf=iGAW0caAhauLSbAW5YjDUi6gDnKsO6+W0Pcgg@mail.gmail.com>
	 <1468065830.5007.10.camel@synopsys.com>
	 <87shviklio.fsf@husum.klickitat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-7"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"lede-dev@lists.infradead.org" <lede-dev@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"aczlan+ledev@gmail.com" <aczlan+ledev@gmail.com>,
	"linux-snps-arc@lists.infradead.org"
	<linux-snps-arc@lists.infradead.org>
To: "russell@personaltelco.net" <russell@personaltelco.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:48263 "EHLO
	smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757551AbcGKGQE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 02:16:04 -0400
In-Reply-To: <87shviklio.fsf@husum.klickitat.com>
Content-Language: en-US
Content-ID: <93B0F65927E85A4D88BCD77ED20DC560@internal.synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Russel,

On Sun, 2016-07-10 at 00:19 -0700, Russell Senior wrote:
+AD4- +AD4- 
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- +AD4- +ACI-Alexey+ACI- +AD0APQ- Alexey Brodkin +ADw-Alexey.Brodkin+AEA-synopsys.com+AD4- writes:
+AD4- Alexey+AD4- Hi Aaron,
+AD4- Alexey+AD4- On Sat, 2016-07-09 at 07:47 -0400, Aaron Z wrote:
+AD4- +AD4- 
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- On Sat, Jul 9, 2016 at 4:37 AM, Alexey Brodkin
+AD4- +AD4- +AD4- +ADw-Alexey.Brodkin+AEA-synopsys.com+AD4- wrote:
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- Hello,
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- I was playing with quite simple bridged setup on different boards
+AD4- +AD4- +AD4- with +AD4- very recent kernels (4.6.3 as of this writing) and found one
+AD4- +AD4- +AD4- interesting +AD4- behavior that I cannot yet understand and googling
+AD4- +AD4- +AD4- din't help here as well.
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- My setup is pretty simple: +AD4-
+AD4- +AD4- +AD4- -------------+AKAAoACgAKAAoACgAKA-------------------+AKAAoACgAKAAoACgAKA--------------------------
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +AD4- HOST+AKAAoACgAKAAoACgAHwAoACgAKAAoACgAKAAoAB8- +ACI-Dumb AP+ACIAoACgAKAAoACgAKAAfACgAKAAoACgAKAAoACgAHw- Wireless
+AD4- +AD4- +AD4- client+AKAAoACgAKAAoACgAKAAfA- +AD4- +AD4- with DHCP +AHwAPA------+AD4-(eth0)+AKAAoACgAKAAoA-(wlan0)+ADw------+AD4AfA-
+AD4- +AD4- +AD4- attempting to+AKAAoACgAKAAoACgAKAAoACgAHw- +AD4- +AD4- server+AKAAoACgAKAAfACgAKAAoACgAKAAoACgAHwAoACgAKAAoABc- br0
+AD4- +AD4- +AD4- /+AKAAoACgAKAAoAB8AKAAoACgAKAAoACgAKAAfA- get settings via DHCP +AHw- +AD4-
+AD4- +AD4- +AD4- -------------+AKAAoACgAKAAoACgAKA-------------------+AKAAoACgAKAAoACgAKA--------------------------
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- +ACo- HOST is my laptop with DHCP server that works for sure.+AKAAoAA+- +ACo-
+AD4- +AD4- +AD4- +ACI-Dumb AP+ACI- is a separate board (I tried ARM-based Wandboard and
+AD4- +AD4- +AD4- ARC-based +AD4- +AKA- AXS10x boards but results are exactly the same) with
+AD4- +AD4- +AD4- wired (eth0) and wireless +AD4- +AKA- (wlan0) network controllers bridged
+AD4- +AD4- +AD4- together (br0). That +ACI-br0+ACI- bridge flawlessly +AD4- +AKA- gets its settings
+AD4- +AD4- +AD4- from DHCP server on host.+AKAAoAA+- +ACo- Wireless client could be either a
+AD4- +AD4- +AD4- smatrphone or another laptop etc but +AD4- +AKA- what's important it should
+AD4- +AD4- +AD4- be configured to get network settings by DHCP as well.
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- +AD4- So what happens +ACI-br0+ACI- always gets network settings from DHCP server
+AD4- +AD4- +AD4- on HOST.+AKAAoAA+- That's fine. But wireless client only reliably gets
+AD4- +AD4- +AD4- settings from DHCP server +AD4- if IPv6 is enabled on +ACI-Dumb AP+ACI- board. If
+AD4- +AD4- +AD4- IPv6 is disabled I may see that +AD4- wireless client sends +ACI-DHCP
+AD4- +AD4- +AD4- Discover+ACI- then server replies with +ACI-DHCP Offer+ACI- but +AD4- that offer
+AD4- +AD4- +AD4- never reaches wireless client.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- Do you have WDS enabled? If not, DHCP has issues in that scenario:
+AD4- +AD4- +AD4- https://wiki.openwrt.org/doc/howto/clientmode
+AD4- If the Dumb AP's wireless interface is in ap-mode, then this shouldn't
+AD4- be an issue.+AKAAoA-It's only client-mode interfaces that have trouble with bridging.
+AD4- 
+AD4- I'd suggest running tcpdump on the Dumb AP's wireless interface and the
+AD4- client's wireless interface and see which of them sees the various parts
+AD4- of the DHCP handshake.

So I did but for DHCP server and wireless client (had no tcpdump on Dump AP
at the moment).

That's what I see on the server:
-----------------------------+AD4-8-------------------------------
No. Time+AKAAoACgAKAAoACgAKAAoA-Source+AKAAoACgAKAAoA-Destination+AKAAoACgAKAAoACg-Protocol Length Info
+AKA-3 0.151181000+AKAAoA-0.0.0.0+AKAAoACgAKA-255.255.255.255+AKAAoA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Discover - Transaction ID 0x31dc321f
11 2.760796000+AKAAoA-10.42.0.1+AKAAoA-10.42.0.13+AKAAoACgAKAAoACgAKA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Offer+AKAAoACgAKA-- Transaction ID 0x31dc321f
14 5.220985000+AKAAoA-0.0.0.0+AKAAoACgAKA-255.255.255.255+AKAAoA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Discover - Transaction ID 0x31dc321f
15 5.221150000+AKAAoA-10.42.0.1+AKAAoA-10.42.0.13+AKAAoACgAKAAoACgAKA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Offer+AKAAoACgAKA-- Transaction ID 0x31dc321f
23 15.649835000 0.0.0.0+AKAAoACgAKA-255.255.255.255+AKAAoA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Discover - Transaction ID 0x31dc321f
24 15.650017000 10.42.0.1+AKAAoA-10.42.0.13+AKAAoACgAKAAoACgAKA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Offer+AKAAoACgAKA-- Transaction ID 0x31dc321f
32 25.648589000 0.0.0.0+AKAAoACgAKA-255.255.255.255+AKAAoA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Discover - Transaction ID 0x31dc321f
33 25.648758000 10.42.0.1+AKAAoA-10.42.0.13+AKAAoACgAKAAoACgAKA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Offer+AKAAoACgAKA-- Transaction ID 0x31dc321f
43 35.864567000 0.0.0.0+AKAAoACgAKA-255.255.255.255+AKAAoA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Discover - Transaction ID 0x31dc321f
48 38.832837000 10.42.0.1+AKAAoA-10.42.0.13+AKAAoACgAKAAoACgAKA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Offer+AKAAoACgAKA-- Transaction ID 0x31dc321f
-----------------------------+AD4-8-------------------------------

That's on the wireless client:
-----------------------------+AD4-8-------------------------------
No.+AKAAoA-Time+AKAAoACgAKAAoACgAKAAoACgAKAAoA-Source+AKAAoACg-Destination+AKAAoACgAKAAoACg-Protocol Length Info
1171 94.192971000+AKAAoACg-0.0.0.0+AKAAoA-255.255.255.255+AKAAoA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Discover - Transaction ID 0x31dc321f
1182 99.263686000+AKAAoACg-0.0.0.0+AKAAoA-255.255.255.255+AKAAoA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Discover - Transaction ID 0x31dc321f
1185 109.692642000+AKAAoA-0.0.0.0+AKAAoA-255.255.255.255+AKAAoA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Discover - Transaction ID 0x31dc321f
1186 119.691474000+AKAAoA-0.0.0.0+AKAAoA-255.255.255.255+AKAAoA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Discover - Transaction ID 0x31dc321f
1190 129.907507000+AKAAoA-0.0.0.0+AKAAoA-255.255.255.255+AKAAoA-DHCP+AKAAoACgAKAAoA-342+AKAAoACgAKA-DHCP Discover - Transaction ID 0x31dc321f
-----------------------------+AD4-8-------------------------------

I'll try to capture data from Dumb AP sometime soon and will reply to the thread.

-Alexey
