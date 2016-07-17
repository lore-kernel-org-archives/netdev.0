From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: cavium: liquidio: Avoid dma_unmap_single on
 uninitialized ndata
Date: Sat, 16 Jul 2016 22:06:29 -0700 (PDT)
Message-ID: <20160716.220629.880291604451445477.davem@davemloft.net>
References: <1468626136-31783-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468626136-31783-1-git-send-email-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 15 Jul 2016 16:42:16 -0700

> The label lio_xmit_failed is used 3 times through liquidio_xmit() but it
> always makes a call to dma_unmap_single() using potentially
> uninitialized variables from "ndata" variable. Out of the 3 gotos, 2 run
> after ndata has been initialized, and had a prior dma_map_single() call.
> 
> Fix this by adding a new error label: lio_xmit_dma_failed which does
> this dma_unmap_single() and then processed with the lio_xmit_failed
> fallthrough.
> 
> Fixes: f21fb3ed364bb ("Add support of Cavium Liquidio ethernet adapters")
> Reported-by: coverity (CID 1309740)
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
