From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 3/3] NetXen: 64-bit memory fixes, driver cleanup
Date: Fri, 17 Nov 2006 08:40:49 -0800
Message-ID: <20061117084049.555e14d0@localhost.localdomain>
References: <200611171536.kAHFa3os005563@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [65.172.181.25] ([65.172.181.25]:4833 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S933720AbWKQQn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 11:43:27 -0500
To: "Linsys Contractor Amit S. Kale" <amitkale@netxen.com>
In-Reply-To: <200611171536.kAHFa3os005563@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Nov 2006 07:36:03 -0800
"Linsys Contractor Amit S. Kale" <amitkale@netxen.com> wrote:

> NetXen: 1G/10G Ethernet Driver updates
> 	- These fixes take care of driver on machines with >4G memory
> 	- Driver cleanup
> 
> Signed-off-by: Amit S. Kale <amitkale@netxen.com>
> 
>  netxen_nic.h          |   41 ++++++----
>  netxen_nic_ethtool.c  |   19 ++--
>  netxen_nic_hw.c       |   10 +-
>  netxen_nic_hw.h       |    4 
>  netxen_nic_init.c     |   51 +++++++++++-
>  netxen_nic_isr.c      |    3 
>  netxen_nic_main.c     |  204 +++++++++++++++++++++++++++++++++++++++++++++++---
>  netxen_nic_phan_reg.h |   10 +-
>  8 files changed, 293 insertions(+), 49 deletions(-)
> 


If you can't DMA from high memory, then don't set NETIF_F_HIGHDMA, why do
you need explicit bounce buffers.  If you can't DMA from unaligned address,
the write a small routine to copy the skb to a new one.
