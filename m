From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 01/10] ftgmac100: Upgrade to NETIF_F_HW_CSUM
Date: Tue, 11 Apr 2017 13:57:35 +0300
Message-ID: <7d0f6000-3be5-ed70-49d3-3a3916dd79ff@cogentembedded.com>
References: <20170411010436.23290-1-benh@kernel.crashing.org>
 <20170411010436.23290-2-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:34382 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752623AbdDKK5i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 06:57:38 -0400
Received: by mail-lf0-f54.google.com with SMTP id z15so84809387lfd.1
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 03:57:37 -0700 (PDT)
In-Reply-To: <20170411010436.23290-2-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 4/11/2017 4:04 AM, Benjamin Herrenschmidt wrote:

> The documentation describes NETIF_F_IP_CSUM as deprecated
> so let's switch to NETIF_F_HW_CSUM and use the helper to
> handle unhandled protocols.
>
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
>  drivers/net/ethernet/faraday/ftgmac100.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
> index 98b8956..85b650a 100644
> --- a/drivers/net/ethernet/faraday/ftgmac100.c
> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> @@ -637,7 +637,8 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
>  				csum_vlan |= FTGMAC100_TXDES1_TCP_CHKSUM;
>  			else if (ip_proto == IPPROTO_UDP)
>  				csum_vlan |= FTGMAC100_TXDES1_UDP_CHKSUM;
> -		}
> +		} else if (skb_checksum_help(skb))
> +			goto drop;

    Need {} here as well since the 1st branch has it -- see 
Documentation/process/coding-style.rst (the end of the section 3).

[...]

MBR, Sergei
