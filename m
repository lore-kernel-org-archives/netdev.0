From: Aaron Z <aczlan+ledev@gmail.com>
Subject: Re: [LEDE-DEV] DHCP via bridge in case of IPv4
Date: Sat, 9 Jul 2016 07:47:59 -0400
Message-ID: <CAKNoO9oK-_sf=iGAW0caAhauLSbAW5YjDUi6gDnKsO6+W0Pcgg@mail.gmail.com>
References: <1468053400.5007.5.camel@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-snps-arc@lists.infradead.org"
	<linux-snps-arc@lists.infradead.org>,
	"lede-dev@lists.infradead.org" <lede-dev@lists.infradead.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468053400.5007.5.camel@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 9, 2016 at 4:37 AM, Alexey Brodkin
<Alexey.Brodkin@synopsys.com> wrote:
> Hello,
>
> I was playing with quite simple bridged setup on different boards with
> very recent kernels (4.6.3 as of this writing) and found one interesting
> behavior that I cannot yet understand and googling din't help here as well.
>
> My setup is pretty simple:
> -------------       ------------------       -------------------------
> | HOST      |       | "Dumb AP"      |       | Wireless client       |
> | with DHCP |<----->(eth0)     (wlan0)<----->| attempting to         |
> | server    |       |    \ br0 /     |       | get settings via DHCP |
> -------------       ------------------       -------------------------
>
> * HOST is my laptop with DHCP server that works for sure.
> * "Dumb AP" is a separate board (I tried ARM-based Wandboard and ARC-based
>   AXS10x boards but results are exactly the same) with wired (eth0) and wireless
>   (wlan0) network controllers bridged together (br0). That "br0" bridge flawlessly
>   gets its settings from DHCP server on host.
> * Wireless client could be either a smatrphone or another laptop etc but
>   what's important it should be configured to get network settings by DHCP as well.
>
> So what happens "br0" always gets network settings from DHCP server on HOST.
> That's fine. But wireless client only reliably gets settings from DHCP server
> if IPv6 is enabled on "Dumb AP" board. If IPv6 is disabled I may see that
> wireless client sends "DHCP Discover" then server replies with "DHCP Offer" but
> that offer never reaches wireless client.
Do you have WDS enabled? If not, DHCP has issues in that scenario:
https://wiki.openwrt.org/doc/howto/clientmode

Aaron Z
