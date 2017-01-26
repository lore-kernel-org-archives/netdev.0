From: Roi Dayan <roid@mellanox.com>
Subject: Re: [PATCH v2 iproute2] f_flower: don't set TCA_FLOWER_KEY_ETH_TYPE
 for "protocol all"
Date: Thu, 26 Jan 2017 09:13:20 +0200
Message-ID: <b859c71d-c04f-8de2-03af-d6345c86842d@mellanox.com>
References: <20170120190738.GA17163@nvt-d.home.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, <netdev@vger.kernel.org>,
        <bcrl@kvack.org>
To: Benjamin LaHaise <benjamin.lahaise@netronome.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20067.outbound.protection.outlook.com ([40.107.2.67]:20832
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752326AbdAZHNa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 02:13:30 -0500
In-Reply-To: <20170120190738.GA17163@nvt-d.home.kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 20/01/2017 21:07, Benjamin LaHaise wrote:
> v2 - update to address changes in 00697ca19ae3e1118f2af82c3b41ac4335fe918b.
>
> When using the tc flower filter, rules marked with "protocol all" do not
> actually match all packets.  This is due to a bug in f_flower.c that passes
> in ETH_P_ALL in the TCA_FLOWER_KEY_ETH_TYPE attribute when adding a rule.
> Fix this by omitting TCA_FLOWER_KEY_ETH_TYPE if the protocol is set to
> ETH_P_ALL.
>      
> Fixes: 488b41d020fb ("tc: flower no need to specify the ethertype")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
>
> diff --git a/tc/f_flower.c b/tc/f_flower.c
> index 314c2dd..145a856 100644
> --- a/tc/f_flower.c
> +++ b/tc/f_flower.c
> @@ -529,9 +529,11 @@ parse_done:
>   	if (ret)
>   		return ret;
>   
> -	ret = addattr16(n, MAX_MSG, TCA_FLOWER_KEY_ETH_TYPE, eth_type);
> -	if (ret)
> -		return ret;
> +	if (eth_type != htons(ETH_P_ALL)) {
> +		ret = addattr16(n, MAX_MSG, TCA_FLOWER_KEY_ETH_TYPE, eth_type);
> +		if (ret)
> +			return ret;
> +	}
>   
>   	tail->rta_len = (((void *)n)+n->nlmsg_len) - (void *)tail;
>   

Reviewed-by: Roi Dayan <roid@mellanox.com>
