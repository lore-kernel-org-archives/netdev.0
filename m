From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] net: ethernet: renesas: sh_eth: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 10 Aug 2016 11:29:23 +0200
Message-ID: <20160810092923.GF6276@verge.net.au>
References: <1470780289-27496-1-git-send-email-tremyfr@gmail.com>
 <1470780289-27496-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
	geert+renesas@glider.be, andrew@lunn.ch, netdev@vger.kernel.org,
	linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-sh@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1470780289-27496-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CC linux-sh as some of those boards use this driver]

Hi Phillippe,

On Wed, Aug 10, 2016 at 12:04:49AM +0200, Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Thanks this change looks reasonable to me.

I have also tested it as follows on the r8a7790/Lager board and it
appears to work.

Tested-by: Simon Horman <horms+renesas@verge.net.au>

# ethtool -h | head -1
ethtool version 3.1

# ethtool -i eth0
driver: sh-eth
version:
firmware-version:
bus-info: ee700000.ethernet
supports-statistics: yes
supports-test: no
supports-eeprom-access: no
supports-register-dump: yes

# ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Supported pause frame use: Symmetric Receive-only
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
        Advertised pause frame use: Symmetric Receive-only
        Advertised auto-negotiation: Yes
        Link partner advertised link modes:  10baseT/Half 10baseT/Full
                                             100baseT/Half 100baseT/Full
        Link partner advertised pause frame use: No
        Link partner advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Current message level: 0x000000cc (204)
                               link timer rx_err tx_err
        Link detected: yes

# ethtool -s eth0 speed 10 duplex half

--- start kernel messages ---
[  375.640312] sh-eth ee700000.ethernet eth0: Link is Down
[  377.360727] sh-eth ee700000.ethernet eth0: Link is Up - 10Mbps/Half - flow control off
--- end kernel messages ---

# ethtool eth0
Settings for eth0:
        Supported ports: [ TP MII ]
        Supported link modes:   10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
        Supported pause frame use: Symmetric Receive-only
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Link partner advertised link modes:  10baseT/Half 10baseT/Full 
                                             100baseT/Half 100baseT/Full 
        Link partner advertised pause frame use: No
        Link partner advertised auto-negotiation: Yes
        Speed: 10Mb/s
        Duplex: Half
        Port: MII
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Current message level: 0x000000cc (204)
                               link timer rx_err tx_err
        Link detected: yes
