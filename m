From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH v2] net: ti cpsw ethernet: set IFCTL_A bit in MACCONTROL
Date: Mon, 01 Oct 2012 11:25:30 +0200
Message-ID: <5069618A.5020105@gmail.com>
References: <1348773574-30318-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	"David S. Miller" <davem@davemloft.net>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57683 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217Ab2JAJZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 05:25:37 -0400
Received: by bkcjk13 with SMTP id jk13so4776482bkc.19
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2012 02:25:36 -0700 (PDT)
In-Reply-To: <1348773574-30318-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27.09.2012 21:19, Daniel Mack wrote:
> For RMII/RGMII mode operation in 100Mbps, the CPSW needs to set the
> IFCTL_A bits in the MACCONTROL register. For all other PHY modes, this
> bit is unused, so setting it unconditionally shouldn't cause any
> trouble.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Cc: Vaibhav Hiremath <hvaibhav@ti.com>
> Cc: David S. Miller <davem@davemloft.net>

Mugunthan, are you ok with this version? Don't know if it's too late for
the 3.7 spin though, given that the merge window just opened.


Daniel


> ---
>  drivers/net/ethernet/ti/cpsw.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index aa78168..fb1a692 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -386,6 +386,11 @@ static void _cpsw_adjust_link(struct cpsw_slave *slave,
>  			mac_control |= BIT(7);	/* GIGABITEN	*/
>  		if (phy->duplex)
>  			mac_control |= BIT(0);	/* FULLDUPLEXEN	*/
> +
> +		/* set speed_in input in case RMII mode is used in 100Mbps */
> +		if (phy->speed == 100)
> +			mac_control |= BIT(15);
> +
>  		*link = true;
>  	} else {
>  		mac_control = 0;
> 
