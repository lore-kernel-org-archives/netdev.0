From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] bonding: delay up state without speed and duplex in
 802.3ad mode
Date: Fri, 18 Dec 2015 16:37:25 +0300
Message-ID: <56740C15.9080609@cogentembedded.com>
References: <1586.1450389436@famine>
 <1450413386-8867-1-git-send-email-zyjzyj2000@gmail.com>
 <1450413386-8867-2-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org, Boris.Shteinbock@windriver.com
To: zyjzyj2000@gmail.com, j.vosburgh@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:33645 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063AbbLRNh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 08:37:29 -0500
Received: by mail-lf0-f45.google.com with SMTP id p203so73505646lfa.0
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 05:37:28 -0800 (PST)
In-Reply-To: <1450413386-8867-2-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/18/2015 7:36 AM, zyjzyj2000@gmail.com wrote:

> From: yzhu1 <yzhu1@windriver.com>
>
> In 802.3ad mode, the speed and duplex is needed. But in some NICs,
> there is a time span between NIC up state and getting speed and duplex.
> As such, sometimes a slave in 802.3ad mode is in up state without
> speed and duplex. This will make bonding in 802.3ad mode can not
> work well.
>
> To make bonding driver robust and compatible with more NICs, it is
> necessary to delay the up state without speed and duplex in 802.3ad
> mode.
>
> Signed-off-by: yzhu1 <yzhu1@windriver.com>
> ---
>   drivers/net/bonding/bond_main.c |   34 ++++++++++++++++++++++++++++++++++
>   1 file changed, 34 insertions(+)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 9e0f8a7..a1d8708 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -419,6 +419,35 @@ const char *bond_slave_link_status(s8 link)
>   	}
>   }
>
> +/* This function is to check the speed and duplex of a NIC.
> + * Since the speed and duplex of a slave device are very
> + * important to the bonding in the 802.3ad mode. As such,
> + * it is necessary to check the speed and duplex of a slave
> + * device in 802.3ad mode.
> + *
> + * speed != SPEED_UNKNOWN and duplex == DUPLEX_FULL  :  1
> + *                                           others  :  0
> + */
> +static int __check_speed_duplex(struct net_device *netdev)
> +{
> +	struct ethtool_cmd ecmd;
> +	u32 slave_speed = SPEED_UNKNOWN;
> +	int res;
> +
> +	res = __ethtool_get_settings(netdev, &ecmd);
> +	if (res < 0)
> +		return 0;
> +
> +	slave_speed = ethtool_cmd_speed(&ecmd);
> +	if (slave_speed == 0 || slave_speed == ((__u32) -1))
> +		return 0;
> +
> +	if (DUPLEX_FULL != ecmd.duplex)

    Please place the immediate operand to the right of the != operator.

[...]

MBR, Sergei
