From: Matteo Croce <matteo@openwrt.org>
Subject: Re: [PATCH v4] add stealth mode
Date: Wed, 23 Sep 2015 18:36:12 +0200
Message-ID: <CAFnufp2cyZhfy7GRbP1r7xStm4mMdcHKeXmtLDXU1=UfVxtZjQ@mail.gmail.com>
References: <20150915.120057.1457031142615117336.davem@davemloft.net>
 <1442397259-28894-1-git-send-email-matteo@openwrt.org> <20150916110629.GP24810@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150916110629.GP24810@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2015-09-16 13:06 GMT+02:00 Florian Westphal <fw@strlen.de>:
>
> Matteo Croce <matteo@openwrt.org> wrote:
> > Add option to disable any reply not related to a listening socket,
> > like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
> > Also disables ICMP replies to echo request and timestamp.
> > The stealth mode can be enabled selectively for a single interface.
>
> I think it would make more sense to extend the socket match
> in xtables if it can't be used to achive this already.
>
> seems like
> *filter
> :INPUT ACCEPT [0:0]
> -A INPUT -p tcp -m socket --nowildcard -j ACCEPT
> -A INPUT -p tcp -j DROP
> COMMIT
>
> Already does what you want for tcp, udp should work too.
> I'd much rather see xtables and/or nftables to be extended
> with whatever feature(s) are needed to configure such a policy
> rather than pushing this into the core network stack.

The point is to do the filtering without *tables at all,
like /proc/sys/net/ipv4/icmp_echo_ignore_all does for pings

-- 
Matteo Croce
OpenWrt Developer
  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 -----------------------------------------------------
 CHAOS CALMER
 -----------------------------------------------------
  * 1 1/2 oz Gin            Shake with a glassful
  * 1/4 oz Triple Sec       of broken ice and pour
  * 3/4 oz Lime Juice       unstrained into a goblet.
  * 1 1/2 oz Orange Juice
  * 1 tsp. Grenadine Syrup
 -----------------------------------------------------
