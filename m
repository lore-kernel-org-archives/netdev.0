From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] mpc836x: fix failed phy detection for ucc ethernet on MDS
Date: Fri, 16 Mar 2012 14:36:33 -0500
Message-ID: <329E382B-6DB2-4AC0-BC79-59296633FE9E@kernel.crashing.org>
References: <1330345501-24949-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, benh@kernel.crashing.org,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:44052 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756899Ab2CPTjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2012 15:39:40 -0400
In-Reply-To: <1330345501-24949-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Feb 27, 2012, at 6:25 AM, Paul Gortmaker wrote:

> The mpc836x_mds platform has been broken since the commit
> 6fe3264945ee63292cdfb27b6e95bc52c603bb09
> 
>  "netdev/phy: Use mdiobus_read() so that proper locks are taken"
> 
> which caused the fsl_pq_mdio TBI autoprobe to oops.  The oops
> was "fixed" in commit 28d8ea2d568534026ccda3e8936f5ea1e04a86a1
> 
>  "fsl_pq_mdio: Clean up tbi address configuration"
> 
> by simply removing the the autoscan code, and making tbi nodes
> mandatory.  Some of the newer reference platforms were updated
> to have tbi nodes in 220669495bf8b68130a8218607147c7b74c28d2b
> 
>  "powerpc: Add TBI PHY node to first MDIO bus"
> 
> but the older mpc836x didn't get one and hence was just failing
> with -EBUSY as follows:
> 
> fsl-pq_mdio: probe of e0102120.mdio failed with error -16
>   ...
> net eth0: Could not attach to PHY
> eth0: Cannot initialize PHY, aborting.
> 
> Add a TBI node and use the 1st free address for it.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---

applied

- k
