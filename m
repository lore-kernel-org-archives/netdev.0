From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] of: mdio: fixup of_phy_register_fixed_link parsing of
 new bindings
Date: Thu, 19 Jun 2014 23:32:32 +0400
Message-ID: <53A33AD0.2060200@cogentembedded.com>
References: <1403199334-13212-1-git-send-email-rretanubun.work@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	thomas.petazzoni@free-electrons.com
To: Richard Retanubun <rretanubun.work@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:33951 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757784AbaFSTcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 15:32:25 -0400
Received: by mail-la0-f46.google.com with SMTP id el20so1694409lab.5
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2014 12:32:23 -0700 (PDT)
In-Reply-To: <1403199334-13212-1-git-send-email-rretanubun.work@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/19/2014 09:35 PM, Richard Retanubun wrote:

> Fixes commit 3be2a49e5c08 ("of: provide a binding for fixed link PHYs")

> Fix the parsing of the new fixed link dts bindings for duplex,
> pause, and asym_pause by using the correct device node pointer.

> Signed-off-by: Richard Retanubun <rretanubun.work@gmail.com>
> ---
>   drivers/of/of_mdio.c | 8 +++++---
>   1 file changed, 5 insertions(+), 3 deletions(-)

> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 7700ddc..c389e7b 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -290,11 +290,13 @@ int of_phy_register_fixed_link(struct device_node *np)
>   	fixed_link_node = of_get_child_by_name(np, "fixed-link");
>   	if (fixed_link_node) {
>   		status.link = 1;
> -		status.duplex = of_property_read_bool(np, "full-duplex");
> +		status.duplex = of_property_read_bool(fixed_link_node,
> +					"full-duplex");

    The continuation line should start under 'fixed_link_node', according to 
the networking coding style.

>   		if (of_property_read_u32(fixed_link_node, "speed", &status.speed))
>   			return -EINVAL;
> -		status.pause = of_property_read_bool(np, "pause");
> -		status.asym_pause = of_property_read_bool(np, "asym-pause");
> +		status.pause = of_property_read_bool(fixed_link_node, "pause");
> +		status.asym_pause = of_property_read_bool(fixed_link_node,
> +						"asym-pause");

    Same here...

WBR, Sergei
