From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] sundance: PHY address form 0, only for device ID 0x0200
 (IP100A)
Date: Mon, 4 Jun 2007 09:01:19 -0700
Message-ID: <20070604090119.488a2588.randy.dunlap@oracle.com>
References: <1180991079.15274.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com, jeff@garzik.org
To: Jesse Huang <jesse@icplus.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:45513 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755017AbXFDQCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 12:02:09 -0400
In-Reply-To: <1180991079.15274.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 04 Jun 2007 17:04:39 -0400 Jesse Huang wrote:

> From: Jesse Huang <jesse@icplus.com.tw>
> 
> Change Logs:
> Search PHY address form 0, only for device ID 0x0200 (IP100A). Other device are from PHY address 1.
> 
> Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
> ---
> 
>  drivers/net/sundance.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> 5724a72722dfc9cafbb8f273cb82dbf577bd9ad0
> diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
> index e1f912d..914ab29 100644
> --- a/drivers/net/sundance.c
> +++ b/drivers/net/sundance.c
> @@ -562,7 +562,9 @@ #endif
>  	 * It seems some phys doesn't deal well with address 0 being accessed
>  	 * first, so leave address zero to the end of the loop (32 & 31).
>  	 */
> -	for (phy = 1; phy <= 32 && phy_idx < MII_CNT; phy++) {
> +	if(sundance_pci_tbl[np->chip_id].device == 0x0200) phy = 0;

kernel style:
	if (sundance_pci_tbl[np->chip_id].device == 0x0200)
		phy = 0;
	else
		phy = 1;

> +	else phy = 1;
> +	for (; phy <= 32 && phy_idx < MII_CNT; phy++) {
>  		int phyx = phy & 0x1f;
>  		int mii_status = mdio_read(dev, phyx, MII_BMSR);
>  		if (mii_status != 0xffff  &&  mii_status != 0x0000) {
> -- 


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
