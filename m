From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC v1 7/7] net/faraday: Enable offload checksum according
 to device-tree
Date: Tue, 6 Oct 2015 17:19:10 +0300
Message-ID: <5613D85E.30608@cogentembedded.com>
References: <1444100989-3437-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1444100989-3437-8-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:35281 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbbJFOTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 10:19:12 -0400
Received: by lacdq7 with SMTP id dq7so2566569lac.2
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 07:19:11 -0700 (PDT)
In-Reply-To: <1444100989-3437-8-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/6/2015 6:09 AM, Gavin Shan wrote:

> This enables IP/UDP/TCP offload checksum according to information
> passed on from bootloader through device-tree. The offload doesn't
> working properly when the interface works in NCSI mode.
>
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
> ---
>   drivers/net/ethernet/faraday/ftgmac100.c | 6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
> index 1b13fd4..8caed35 100644
> --- a/drivers/net/ethernet/faraday/ftgmac100.c
> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> @@ -1377,7 +1377,11 @@ static int ftgmac100_probe(struct platform_device *pdev)
>
>   	netdev->ethtool_ops = &ftgmac100_ethtool_ops;
>   	netdev->netdev_ops = &ftgmac100_netdev_ops;
> -	netdev->features = NETIF_F_IP_CSUM | NETIF_F_GRO;
> +	if (pdev->dev.of_node &&
> +	    of_get_property(pdev->dev.of_node, "no-hw-checksum", NULL))

    Why not of_property_read_bool()?

> +		netdev->features = NETIF_F_GRO;
> +	else
> +		netdev->features = NETIF_F_IP_CSUM | NETIF_F_GRO;

    Why not set NETIF_F_GRO outside of *if*?

[...]

MBR, Sergei
