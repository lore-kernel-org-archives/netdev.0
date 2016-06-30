From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: bcmsysport: Device stats are unsigned long
Date: Thu, 30 Jun 2016 20:33:36 +0200
Message-ID: <20160630183336.GM7480@lunn.ch>
References: <1467309389-12377-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33507 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068AbcF3Sdo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 14:33:44 -0400
Content-Disposition: inline
In-Reply-To: <1467309389-12377-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2016 at 10:56:29AM -0700, Florian Fainelli wrote:
> On 64bits kernels, device stats are 64bits wide, not 32bits.
> 
> Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bcmsysport.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
> index 543bf38105c9..21f21e23e695 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
> @@ -392,7 +392,11 @@ static void bcm_sysport_get_stats(struct net_device *dev,
>  		else
>  			p = (char *)priv;
>  		p += s->stat_offset;
> -		data[i] = *(u32 *)p;

Hi Florian

Could you not just change this cast from u32 to unsigned long and be
done?

160 struct net_device_stats {
161         unsigned long   rx_packets;
162         unsigned long   tx_packets;

	    Andrew
