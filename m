From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/1] stmmac: fix oops on rmmod after assigning ip
 addr
Date: Thu, 16 Apr 2015 14:14:27 -0400 (EDT)
Message-ID: <20150416.141427.1085248733060476395.davem@davemloft.net>
References: <1429203363-10919-1-git-send-email-pure.logic@nexus-software.ie>
	<1429203363-10919-2-git-send-email-pure.logic@nexus-software.ie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	andriy.shevchenko@linux.intel.com, hock.leong.kweh@intel.com,
	boon.leong.ong@intel.com, dan.odonovan@emutex.com,
	linux-kernel@vger.kernel.org
To: pure.logic@nexus-software.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34533 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611AbbDPSO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 14:14:29 -0400
In-Reply-To: <1429203363-10919-2-git-send-email-pure.logic@nexus-software.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Date: Thu, 16 Apr 2015 17:56:03 +0100

> An oops exists in the flow of stmmac_release().
> phy_ethtool_get_wol() depends on phydev->drv.
> phydev->drv will be null after stmmac_mdio_unreg() completes.
> 
> Steps to reproduce on Quark X1000:
> 
> 1. ifconfig eth0 192.168.0.1
> 2. rmmod stmmac_pci
> 
> To fix this stmmac_mdio_unreg() should be run after unregister_netdev().
> 
> Signed-off-by: Bryan O'Donoghue <pure.logic@nexus-software.ie>
> Reported-by: Dan O'Donovan <dan.odonovan@emutex.com>

Applied.
