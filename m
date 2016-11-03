From: Douglas Miller <dougmill@linux.vnet.ibm.com>
Subject: Re: [PATCH net] ehea: fix operation state report
Date: Thu, 3 Nov 2016 07:19:50 -0500
Message-ID: <8de471c6-a7c7-7c22-c4b7-cd029764e922@linux.vnet.ibm.com>
References: <1478168180-18371-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zhou@redhat.com
To: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57303 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752280AbcKCMT5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 08:19:57 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA3CJKhI088970
        for <netdev@vger.kernel.org>; Thu, 3 Nov 2016 08:19:56 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0a-001b2d01.pphosted.com with ESMTP id 26fx2xntc9-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 08:19:56 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <dougmill@linux.vnet.ibm.com>;
        Thu, 3 Nov 2016 08:19:55 -0400
In-Reply-To: <1478168180-18371-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2016 05:16 AM, Guilherme G. Piccoli wrote:
> Currently the ehea driver is missing a call to netif_carrier_off()
> before the interface bring-up; this is necessary in order to
> initialize the __LINK_STATE_NOCARRIER bit in the net_device state
> field. Otherwise, we observe state UNKNOWN on "ip address" command
> output.
>
> This patch adds a call to netif_carrier_off() on ehea's net device
> open callback.
>
> Reported-by: Xiong Zhou <zhou@redhat.com>
> Reference-ID: IBM bz #137702, Red Hat bz #1089134
> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
> ---
>   drivers/net/ethernet/ibm/ehea/ehea_main.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> index 54efa9a..bd719e2 100644
> --- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
> +++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> @@ -2446,6 +2446,8 @@ static int ehea_open(struct net_device *dev)
>
>   	netif_info(port, ifup, dev, "enabling port\n");
>
> +	netif_carrier_off(dev);
> +
>   	ret = ehea_up(dev);
>   	if (!ret) {
>   		port_napi_enable(port);

Signed-off-by: Douglas Miller <dougmill@linux.vnet.ibm.com>
