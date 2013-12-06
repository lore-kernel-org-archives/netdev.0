From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/7] net: of_mdio: do not overwrite PHY interrupt configuration
Date: Fri, 06 Dec 2013 03:45:04 +0300
Message-ID: <52A11E10.5080909@cogentembedded.com>
References: <1386283936-26104-1-git-send-email-florian@openwrt.org> <1386283936-26104-4-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, grant.likely@linaro.org,
	devicetree@vger.kernel.org, abrodkin@synopsys.com,
	rob.herring@calxeda.com, mark.rutland@arm.com,
	sebastian.hesselbarth@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:52460 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107Ab3LEXpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:45:03 -0500
Received: by mail-la0-f50.google.com with SMTP id el20so10864795lab.9
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 15:45:01 -0800 (PST)
In-Reply-To: <1386283936-26104-4-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/06/2013 01:52 AM, Florian Fainelli wrote:

> From: Florian Fainelli <f.fainelli@gmail.com>

> If irq_of_parse_and_map fails to find an interrupt line for a given PHY,
> we will force the PHY interrupt to be PHY_POLL, completely overriding
> the previous value that the MDIO bus may have set for us (e.g:
> PHY_IGNORE_INTERRUPT). In case of failure, just restore the previous
> value.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   drivers/of/of_mdio.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)

> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index f93ebca..4923ab2 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
[...]
> @@ -37,10 +37,11 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>   		return 1;
>
>   	if (mdio->irq) {
> +		prev_irq= mdio->irq[addr];

    You forgot space before =.

WBR, Sergei
