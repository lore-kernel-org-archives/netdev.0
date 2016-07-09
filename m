From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [LEDE-DEV] DHCP via bridge in case of IPv4
Date: Sat, 9 Jul 2016 12:05:07 +0000
Message-ID: <1468065830.5007.10.camel@synopsys.com>
References: <1468053400.5007.5.camel@synopsys.com>
	 <CAKNoO9oK-_sf=iGAW0caAhauLSbAW5YjDUi6gDnKsO6+W0Pcgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-7"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"lede-dev@lists.infradead.org" <lede-dev@lists.infradead.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-snps-arc@lists.infradead.org"
	<linux-snps-arc@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "aczlan+ledev@gmail.com" <aczlan+ledev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:42267 "EHLO
	smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbcGIMFL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 08:05:11 -0400
In-Reply-To: <CAKNoO9oK-_sf=iGAW0caAhauLSbAW5YjDUi6gDnKsO6+W0Pcgg@mail.gmail.com>
Content-Language: en-US
Content-ID: <4ABCE8725B895B4A845E189A8BC0D737@internal.synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Aaron,

On Sat, 2016-07-09 at 07:47 -0400, Aaron Z wrote:
+AD4- On Sat, Jul 9, 2016 at 4:37 AM, Alexey Brodkin
+AD4- +ADw-Alexey.Brodkin+AEA-synopsys.com+AD4- wrote:
+AD4- +AD4- 
+AD4- +AD4- Hello,
+AD4- +AD4- 
+AD4- +AD4- I was playing with quite simple bridged setup on different boards with
+AD4- +AD4- very recent kernels (4.6.3 as of this writing) and found one interesting
+AD4- +AD4- behavior that I cannot yet understand and googling din't help here as well.
+AD4- +AD4- 
+AD4- +AD4- My setup is pretty simple:
+AD4- +AD4- -------------+AKAAoACgAKAAoACgAKA-------------------+AKAAoACgAKAAoACgAKA--------------------------
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- HOST+AKAAoACgAKAAoACgAHwAoACgAKAAoACgAKAAoAB8- +ACI-Dumb AP+ACIAoACgAKAAoACgAKAAfACgAKAAoACgAKAAoACgAHw- Wireless client+AKAAoACgAKAAoACgAKAAfA-
+AD4- +AD4- +AD4- with DHCP +AHwAPA------+AD4-(eth0)+AKAAoACgAKAAoA-(wlan0)+ADw------+AD4AfA- attempting to+AKAAoACgAKAAoACgAKAAoACgAHw-
+AD4- +AD4- +AD4- server+AKAAoACgAKAAfACgAKAAoACgAKAAoACgAHwAoACgAKAAoABc- br0 /+AKAAoACgAKAAoAB8AKAAoACgAKAAoACgAKAAfA- get settings via DHCP +AHw-
+AD4- +AD4- -------------+AKAAoACgAKAAoACgAKA-------------------+AKAAoACgAKAAoACgAKA--------------------------
+AD4- +AD4- 
+AD4- +AD4- +ACo- HOST is my laptop with DHCP server that works for sure.
+AD4- +AD4- +ACo- +ACI-Dumb AP+ACI- is a separate board (I tried ARM-based Wandboard and ARC-based
+AD4- +AD4- +AKA- AXS10x boards but results are exactly the same) with wired (eth0) and wireless
+AD4- +AD4- +AKA- (wlan0) network controllers bridged together (br0). That +ACI-br0+ACI- bridge flawlessly
+AD4- +AD4- +AKA- gets its settings from DHCP server on host.
+AD4- +AD4- +ACo- Wireless client could be either a smatrphone or another laptop etc but
+AD4- +AD4- +AKA- what's important it should be configured to get network settings by DHCP as well.
+AD4- +AD4- 
+AD4- +AD4- So what happens +ACI-br0+ACI- always gets network settings from DHCP server on HOST.
+AD4- +AD4- That's fine. But wireless client only reliably gets settings from DHCP server
+AD4- +AD4- if IPv6 is enabled on +ACI-Dumb AP+ACI- board. If IPv6 is disabled I may see that
+AD4- +AD4- wireless client sends +ACI-DHCP Discover+ACI- then server replies with +ACI-DHCP Offer+ACI- but
+AD4- +AD4- that offer never reaches wireless client.
+AD4- 
+AD4-
+AD4- Do you have WDS enabled? If not, DHCP has issues in that scenario:
+AD4- https://wiki.openwrt.org/doc/howto/clientmode

I don't have WDS enabled. I tried to have as simple setup as possible.
Still from what I see in the Wiki article above problem happens when
there're 4 devices in the chain, right? Because as it says:
------------------------+AD4-8------------------------
The 802.11 standard only uses three MAC addresses for frames transmitted between
the Access Point and the Station. Frames transmitted from the Station to the AP
don't include the ethernet source MAC of the requesting host and response frames
are missing the destination ethernet MAC to address the target host behind the
client bridge.
------------------------+AD4-8------------------------

But in my case I only have 3 devices in the chain so I would think it's
something else but issue described in the article.

Anyways thanks for the hint.

-Alexey
