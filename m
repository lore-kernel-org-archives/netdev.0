From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch v3 08/11] net: ethernet: xilinx: Generate random mac if
 none found
Date: Thu, 1 Sep 2016 13:52:37 +0300
Message-ID: <3e2dea83-ee59-2980-3a9d-50da04271158@cogentembedded.com>
References: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472661352-11983-9-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: soren.brinkmann@xilinx.com, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org, michal.simek@xilinx.com,
        netdev@vger.kernel.org
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>,
        monstr@monstr.eu, ralf@linux-mips.org, tglx@linutronix.de,
        jason@lakedaemon.net, marc.zyngier@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:34650 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753187AbcIAKwl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 06:52:41 -0400
Received: by mail-lf0-f54.google.com with SMTP id p41so38933764lfi.1
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 03:52:40 -0700 (PDT)
In-Reply-To: <1472661352-11983-9-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/31/2016 7:35 PM, Zubair Lutfullah Kakakhel wrote:

> At the moment, if the emaclite device doesn't find a mac address
> from any source, it simply uses 0x0 with a warning printed.
>
> Instead of using a 0x0 mac address, use a randomly generated one.
>
> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
[...]

> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> index 3cee84a..22e5a5a 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> @@ -1134,8 +1134,10 @@ static int xemaclite_of_probe(struct platform_device *ofdev)
>  	if (mac_address)
>  		/* Set the MAC address. */
>  		memcpy(ndev->dev_addr, mac_address, ETH_ALEN);
> -	else
> -		dev_warn(dev, "No MAC address found\n");
> +	else {
> +		dev_warn(dev, "No MAC address found. Generating Random one\n");
> +		eth_hw_addr_random(ndev);
> +	}

    All branches of the *if* statement should have {} if at least one has 
them, see Documentation/CodingStyle, chaoter 3.

[...]

MBR, Sergei
