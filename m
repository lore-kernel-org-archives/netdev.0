From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch for 2.6.25? 1/1] bonding: fix sysfs attribute handling
Date: Thu, 27 Mar 2008 08:22:32 -0400
Message-ID: <47EB9188.5080500@garzik.org>
References: <200803270747.m2R7lUkT024210@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, lpechacek@suse.cz,
	fubar@us.ibm.com, stable@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56850 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751550AbYC0MWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 08:22:39 -0400
In-Reply-To: <200803270747.m2R7lUkT024210@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Libor Pechacek <lpechacek@suse.cz>
> 
> For bonding interfaces any attempt to read the sysfs directory contents after
> module removal results in an oops.  The fix is to release sysfs attributes for
> the interfaces upon module unload.
> 
> Signed-off-by: Libor Pechacek <lpechacek@suse.cz>
> Acked-by: Jay Vosburgh <fubar@us.ibm.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: <stable@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/bonding/bond_main.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff -puN drivers/net/bonding/bond_main.c~bonding-fix-sysfs-attribute-handling drivers/net/bonding/bond_main.c
> --- a/drivers/net/bonding/bond_main.c~bonding-fix-sysfs-attribute-handling
> +++ a/drivers/net/bonding/bond_main.c
> @@ -4528,8 +4528,7 @@ static void bond_free_all(void)
>  		netif_tx_unlock_bh(bond_dev);
>  		/* Release the bonded slaves */
>  		bond_release_all(bond_dev);
> -		bond_deinit(bond_dev);
> -		unregister_netdevice(bond_dev);
> +		bond_destroy(bond);

sent upstream already (davem has it in net-2.6, bound for upstream)


