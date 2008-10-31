From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/3] bonding: fix miimon failure counter
Date: Fri, 31 Oct 2008 00:49:22 -0400
Message-ID: <490A8E52.4010402@pobox.com>
References: <1225413676-13579-1-git-send-email-fubar@us.ibm.com> <1225413676-13579-2-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54211 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753893AbYJaEt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 00:49:27 -0400
In-Reply-To: <1225413676-13579-2-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> During the rework of the mii monitor for:
> 
> commit f0c76d61779b153dbfb955db3f144c62d02173c2
> Author: Jay Vosburgh <fubar@us.ibm.com>
> Date:   Wed Jul 2 18:21:58 2008 -0700
> 
>     bonding: refactor mii monitor
> 
> 	I left out the increment of the link failure counter.  This
> patch corrects that omission.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> ---
>  drivers/net/bonding/bond_main.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 832739f..85de1d0 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2376,6 +2376,9 @@ static void bond_miimon_commit(struct bonding *bond)
>  			continue;
>  
>  		case BOND_LINK_DOWN:
> +			if (slave->link_failure_count < UINT_MAX)
> +				slave->link_failure_count++;
> +
>  			slave->link = BOND_LINK_DOWN;

applied 1-3


