From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH net-next v2 6/9] net: mv643xx_eth: use phy_init_hw to
 reset PHY
Date: Mon, 09 Dec 2013 21:09:27 +0100
Message-ID: <52A62377.7050406@gmail.com>
References: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com> <1386363698-8407-7-git-send-email-f.fainelli@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
	afleming@gmail.com, kyle@moffetthome.net
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:34150 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932101Ab3LIUJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 15:09:33 -0500
Received: by mail-ea0-f177.google.com with SMTP id n15so1816131ead.8
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 12:09:32 -0800 (PST)
In-Reply-To: <1386363698-8407-7-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2013 10:01 PM, Florian Fainelli wrote:
> Instead of open-coding a PHY reset through the MII BMCR register, use
> phy_init_hw() which does that for us and will also make sure that PHY
> fixups are applied if required. We also remove a call to phy_reset()
> due to the following sequence of calls in the driver:
>
> phy_scan()
> 	-> phy_connect()
> 		-> phy_connect_direct()
> 			-> phy_attach_direct()
> 				-> phy_init_hw()
>
> and we only have a call to phy_init() after phy_scan().
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes since v2:
> - improved commit message and explain why phy_reset() can go away
>    entirely

Series tested on mv643xx_eth with Marvell Dove SoC.

Tested-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

>   drivers/net/ethernet/marvell/mv643xx_eth.c | 21 +--------------------
>   1 file changed, 1 insertion(+), 20 deletions(-)
