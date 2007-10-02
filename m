From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 09/13] forcedeth: "no link" is informational
Date: Tue, 2 Oct 2007 14:49:24 -0700
Message-ID: <20071002144924.2055022d@freepuppy.rosehill>
References: <200710022111.l92LBf6c022501@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	eswierk@arastra.com, aabdulla@nvidia.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40203 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753886AbXJBVtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:49:42 -0400
In-Reply-To: <200710022111.l92LBf6c022501@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 02 Oct 2007 14:11:41 -0700
akpm@linux-foundation.org wrote:

> From: "Ed Swierk" <eswierk@arastra.com>
> 
> Log "no link during initialization" at KERN_INFO as it's not an error, and
> occurs every time the interface comes up (when the forcedeth-phy-power-down
> patch is applied).
> 
> Signed-off-by: Ed Swierk <eswierk@arastra.com>
> Cc: Ayaz Abdulla <aabdulla@nvidia.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/forcedeth.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN drivers/net/forcedeth.c~forcedeth-no-link-is-informational drivers/net/forcedeth.c
> --- a/drivers/net/forcedeth.c~forcedeth-no-link-is-informational
> +++ a/drivers/net/forcedeth.c
> @@ -4921,7 +4921,7 @@ static int nv_open(struct net_device *de
>  	if (ret) {
>  		netif_carrier_on(dev);
>  	} else {
> -		printk("%s: no link during initialization.\n", dev->name);
> +		printk(KERN_INFO "%s: no link during initialization.\n", dev->name);
>  		netif_carrier_off(dev);
>  	}
>  	if (oom)

Driver should use netif_msg_link_up()


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
