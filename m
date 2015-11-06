From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 4/5] bnxt_en: Fix comparison of u16 sw_id against
 negative value.
Date: Fri, 6 Nov 2015 14:57:54 +0300
Message-ID: <563C95C2.6060606@cogentembedded.com>
References: <1446758751-27999-1-git-send-email-mchan@broadcom.com>
 <1446758751-27999-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>
To: Michael Chan <mchan@broadcom.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:33099 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032739AbbKFL56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 06:57:58 -0500
Received: by lbbkw15 with SMTP id kw15so50157712lbb.0
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2015 03:57:55 -0800 (PST)
In-Reply-To: <1446758751-27999-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/6/2015 12:25 AM, Michael Chan wrote:

> Assign the return value from bitmap_find_free_region() to an integer
> variable and check for negative error codes first, before assigning
> the bit ID to the unsigned sw_id field.
>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>   drivers/net/ethernet/broadcom/bnxt/bnxt.c | 9 +++++----
>   1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> index a62deff..db15c5e 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> @@ -5307,7 +5307,7 @@ static int bnxt_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
>   	struct bnxt_ntuple_filter *fltr, *new_fltr;
>   	struct flow_keys *fkeys;
>   	struct ethhdr *eth = (struct ethhdr *)skb_mac_header(skb);
> -	int rc = 0, idx;
> +	int rc = 0, idx, bit_id;

    I'd use the already declared 'rc' variable.

[...]

MBR, Sergei
