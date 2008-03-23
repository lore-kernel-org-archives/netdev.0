From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] bonding: Fix sysfs attribute handling
Date: Sat, 22 Mar 2008 17:27:04 -0700
Message-ID: <20080322172704.49fa557b.akpm@linux-foundation.org>
References: <200803211452.55982.lpechacek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable@kernel.org
To: Libor Pechacek <lpechacek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59351 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753692AbYCWA1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 20:27:44 -0400
In-Reply-To: <200803211452.55982.lpechacek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Mar 2008 14:52:55 +0100 Libor Pechacek <lpechacek@suse.cz> wrote:

> bonding: Fix sysfs attribute handling
> 
> For bonding interfaces any attempt to read the sysfs directory contents after
> module removal results in an oops.  The fix is to release sysfs attributes
> for the interfaces upon module unload.
> 
> Signed-off-by: Libor Pechacek <lpechacek@suse.cz>
> --
>  drivers/net/bonding/bond_main.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 0942d82..33767d4 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4528,8 +4528,7 @@ static void bond_free_all(void)
>  		netif_tx_unlock_bh(bond_dev);
>  		/* Release the bonded slaves */
>  		bond_release_all(bond_dev);
> -		bond_deinit(bond_dev);
> -		unregister_netdevice(bond_dev);
> +		bond_destroy(bond);
>  	}

Is this also needed in 2.6.24.x?
