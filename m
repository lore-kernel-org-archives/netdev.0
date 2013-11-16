From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: call phy_scan_fixups() after PHY reset
Date: Fri, 15 Nov 2013 21:00:45 -0500 (EST)
Message-ID: <20131115.210045.517718888602958910.davem@davemloft.net>
References: <20131105.150153.251029756944194421.davem@davemloft.net>
	<5286C054.9090602@cogentembedded.com>
	<CAGVrzcaKA7T7Cppg0g29wsUZBu4-6+AY+6teH1SWSiT=D7RQBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com,
	nobuhiro.iwamatsu.yj@renesas.com, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, laurent.pinchart+renesas@ideasonboard.com
To: f.fainelli@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcaKA7T7Cppg0g29wsUZBu4-6+AY+6teH1SWSiT=D7RQBQ@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 15 Nov 2013 16:04:52 -0800

> Quite a lot of PHYs actually require a reset through BMCR_RESET when
> resuming from S2/S3 sleep states and even if they do not, it does not
> hurt doing so, I would welcome a generic solution to do that which
> would not circumvent the libphy state machine and APIs.
> idea would be to:

There was recently a patch I had to reject which had the same problem,
it wanted to BMCR_RESET the PHY when the link goes down to avoid a
problem with the hardware that causes a hang.

I brought up the same objection you are here, namely that resetting
the chip puts the hardware and phylib out of sync wrt. what is
configured into the chip.

So the generic solution you suggest here could help that driver
achieve what it wants too.
