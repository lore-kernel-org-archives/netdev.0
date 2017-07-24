From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 03/18] net: mvpp2: set the SMI PHY address when
 connecting to the PHY
Date: Mon, 24 Jul 2017 19:40:01 +0300
Message-ID: <7ccc9080-5967-5728-bb1e-f41b9c91b254@cogentembedded.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-4-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:33832 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755402AbdGXQkF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 12:40:05 -0400
Received: by mail-lf0-f45.google.com with SMTP id g25so42761480lfh.1
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 09:40:04 -0700 (PDT)
In-Reply-To: <20170724134848.19330-4-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 07/24/2017 04:48 PM, Antoine Tenart wrote:

> When connecting to the PHY, explicitly set the SMI PHY address in the
> controller registers to configure a given port to be connected to the
> selected PHY.
>
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvpp2.c | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
>
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index 1e592abc9067..6ffff929b22a 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
[...]
> @@ -5954,6 +5958,16 @@ static int mvpp2_phy_connect(struct mvpp2_port *port)
>  	port->duplex  = 0;
>  	port->speed   = 0;
>
> +	if (priv->hw_version != MVPP22)
> +		return 0;
> +
> +	/* Set the SMI PHY address */
> +	if (of_property_read_u32(port->phy_node, "reg", &phy_addr)) {
> +		netdev_err(port->dev, "cannot find the PHY address\n");
> +		return -EINVAL;

    Wny not propagte the error from of_property_read_u32()?

[...]

MBR, Sergei
