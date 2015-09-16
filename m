From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v4] add stealth mode
Date: Wed, 16 Sep 2015 13:06:29 +0200
Message-ID: <20150916110629.GP24810@breakpoint.cc>
References: <20150915.120057.1457031142615117336.davem@davemloft.net>
 <1442397259-28894-1-git-send-email-matteo@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matteo Croce <matteo@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1442397259-28894-1-git-send-email-matteo@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matteo Croce <matteo@openwrt.org> wrote:
> Add option to disable any reply not related to a listening socket,
> like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
> Also disables ICMP replies to echo request and timestamp.
> The stealth mode can be enabled selectively for a single interface.

I think it would make more sense to extend the socket match
in xtables if it can't be used to achive this already.

seems like
*filter
:INPUT ACCEPT [0:0]
-A INPUT -p tcp -m socket --nowildcard -j ACCEPT
-A INPUT -p tcp -j DROP
COMMIT

Already does what you want for tcp, udp should work too.
I'd much rather see xtables and/or nftables to be extended
with whatever feature(s) are needed to configure such a policy
rather than pushing this into the core network stack.
