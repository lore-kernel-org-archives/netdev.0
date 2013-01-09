From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: Re: [PATCH net-next] igbvf: fix setting
 addr_assign_type	if PF is up
Date: Wed, 9 Jan 2013 17:09:55 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D1F8B527A@FMSMSX107.amr.corp.intel.com>
References: <1357725564-5581-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>
To: Stefan Assmann <sassmann@kpanic.de>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1357725564-5581-1-git-send-email-sassmann@kpanic.de>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Stefan Assmann [mailto:sassmann@kpanic.de]
> Sent: Wednesday, January 09, 2013 1:59 AM
> To: netdev@vger.kernel.org
> Cc: e1000-devel@lists.sourceforge.net; sassmann@kpanic.de
> Subject: [E1000-devel] [PATCH net-next] igbvf: fix setting
> addr_assign_type if PF is up
> 
> When the PF is up and igbvf is loaded the MAC address is not generated
> using eth_hw_addr_random(). This results in addr_assign_type not to be
> set.
> Make sure it gets set.
> 

NAK - In this case, the address may or may not be random. The user may
have (and should have!) explicitly set this address from the host to
ensure that the VF device receives the same address each time it boots.

-Mitch

> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/igbvf/netdev.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c
> b/drivers/net/ethernet/intel/igbvf/netdev.c
> index 53281ff..6a698c5 100644
> --- a/drivers/net/ethernet/intel/igbvf/netdev.c
> +++ b/drivers/net/ethernet/intel/igbvf/netdev.c
> @@ -2746,6 +2746,7 @@ static int igbvf_probe(struct pci_dev *pdev, const
> struct pci_device_id *ent)
>  			dev_err(&pdev->dev, "Error reading MAC address\n");
>  			goto err_hw_init;
>  		}
> +		netdev->addr_assign_type = NET_ADDR_RANDOM;
>  		memcpy(netdev->dev_addr, adapter->hw.mac.addr,
>  			netdev->addr_len);
>  	}
> --
> 1.8.0.2
> 
> 
> ------------------------------------------------------------------------
> ------
> Master Java SE, Java EE, Eclipse, Spring, Hibernate, JavaScript, jQuery
> and much more. Keep your Java skills current with LearnJavaNow -
> 200+ hours of step-by-step video tutorials by Java experts.
> SALE $49.99 this month only -- learn more at:
> http://p.sf.net/sfu/learnmore_122612
> _______________________________________________
> E1000-devel mailing list
> E1000-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/e1000-devel
> To learn more about Intel&#174; Ethernet, visit
> http://communities.intel.com/community/wired

------------------------------------------------------------------------------
Master Java SE, Java EE, Eclipse, Spring, Hibernate, JavaScript, jQuery
and much more. Keep your Java skills current with LearnJavaNow -
200+ hours of step-by-step video tutorials by Java experts.
SALE $49.99 this month only -- learn more at:
http://p.sf.net/sfu/learnmore_122612 
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
