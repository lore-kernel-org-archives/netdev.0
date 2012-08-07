From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH] netdev/phy: skip disabled mdio-mux nodes
Date: Tue, 07 Aug 2012 09:59:25 -0700
Message-ID: <5021496D.8070200@gmail.com>
References: <1344358266-5450-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: david.daney@cavium.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>
To: Timur Tabi <timur@freescale.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:45245 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755592Ab2HGQ73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 12:59:29 -0400
Received: by pbbrr13 with SMTP id rr13so4579397pbb.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 09:59:28 -0700 (PDT)
In-Reply-To: <1344358266-5450-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2012 09:51 AM, Timur Tabi wrote:
> The mdio-mux driver scans all child mdio nodes, without regard to whether
> the node is actually used.  Some device trees include all possible
> mdio-mux nodes and rely on the boot loader to disable those that are not
> present, based on some run-time configuration.  Those nodes need to be
> skipped.
>
> Signed-off-by: Timur Tabi<timur@freescale.com>
> ---
>   drivers/net/phy/mdio-mux.c |    9 +++++++++
>   1 files changed, 9 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
> index 5c12018..d0c231e 100644
> --- a/drivers/net/phy/mdio-mux.c
> +++ b/drivers/net/phy/mdio-mux.c
> @@ -135,6 +135,15 @@ int mdio_mux_init(struct device *dev,
>   	for_each_child_of_node(dev->of_node, child_bus_node) {
>   		u32 v;
>
> +		/*
> +		 * Some device trees include all possible mdio-mux nodes and
> +		 * rely on the boot loader to disable those that are not
> +		 * present, based on some run-time configuration.  Those nodes
> +		 * need to be skipped.
> +		 */
> +		if (!of_device_is_available(child_bus_node))
> +			continue;


Although this will get the job done, I don't think it is the cleanest 
approach.

Would it be better to create a new iterator 
(for_each_available_child_of_node perhaps) that skips the unavailable 
nodes?  This seems like a general problem that is not restricted to mdio 
multiplexers.

David Daney
