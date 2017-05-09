From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: fec: select queue depending on VLAN priority
Date: Tue, 9 May 2017 14:15:12 +0200
Message-ID: <20170509121512.GA16665@lunn.ch>
References: <20170509053708.2573-1-stefan@agner.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fugang.duan@nxp.com, festevam@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Stefan Agner <stefan@agner.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170509053708.2573-1-stefan@agner.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 08, 2017 at 10:37:08PM -0700, Stefan Agner wrote:
> Since the addition of the multi queue code with commit 59d0f7465644
> ("net: fec: init multi queue date structure") the queue selection
> has been handelt by the default transmit queue selection
> implementation which tries to evenly distribute the traffic across
> all available queues. This selection presumes that the queues are
> using an equal priority, however, the queues 1 and 2 are actually
> of higher priority (the classification of the queues is enabled in
> fec_enet_enable_ring).
> 
> This can lead to net scheduler warnings and continuous TX ring
> dumps when exercising the system with iperf.
> 
> Use only queue 0 for all common traffic (no VLAN and P802.1p
> priority 0 and 1) and route level 2-7 through queue 1 and 2.

Hi Stefan

Did you try:

vconfig set_egress_map eth0.42 0 7
ip addr add 10.42.42.42/24 eth0.42
iperf -c 10.42.42.1

i.e. send a continuous stream on one of the higher priority queues.

>From what was said earlier in this thread, isn't queue 0 going to be
starved? As well as this patch, don't we also need some default
bandwidth allocations to the queues to ensure queue 0 does get some
bandwidth?

	Andrew
