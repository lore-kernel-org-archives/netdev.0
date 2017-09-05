From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ncsi: fix ncsi_vlan_rx_{add,kill}_vid references
Date: Tue, 05 Sep 2017 09:12:43 -0700 (PDT)
Message-ID: <20170905.091243.2291345820364652641.davem@davemloft.net>
References: <20170905080615.1131665-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gwshan@linux.vnet.ibm.com, sam@mendozajonas.com, joel@jms.id.au,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170905080615.1131665-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue,  5 Sep 2017 10:05:47 +0200

> We get a new link error in allmodconfig kernels after ftgmac100
> started using the ncsi helpers:
> 
> ERROR: "ncsi_vlan_rx_kill_vid" [drivers/net/ethernet/faraday/ftgmac100.ko] undefined!
> ERROR: "ncsi_vlan_rx_add_vid" [drivers/net/ethernet/faraday/ftgmac100.ko] undefined!
> 
> Related to that, we get another error when CONFIG_NET_NCSI is disabled:
> 
> drivers/net/ethernet/faraday/ftgmac100.c:1626:25: error: 'ncsi_vlan_rx_add_vid' undeclared here (not in a function); did you mean 'ncsi_start_dev'?
> drivers/net/ethernet/faraday/ftgmac100.c:1627:26: error: 'ncsi_vlan_rx_kill_vid' undeclared here (not in a function); did you mean 'ncsi_vlan_rx_add_vid'?
> 
> This fixes both problems at once, using a 'static inline' stub helper
> for the disabled case, and exporting the functions when they are present.
> 
> Fixes: 51564585d8c6 ("ftgmac100: Support NCSI VLAN filtering when available")
> Fixes: 21acf63013ed ("net/ncsi: Configure VLAN tag filter")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
