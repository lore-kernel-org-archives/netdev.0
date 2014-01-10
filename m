From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/23] netfilter: nft_reject: fix compilation warning
 if NF_TABLES_IPV6 is disabled
Date: Fri, 10 Jan 2014 14:39:27 -0500 (EST)
Message-ID: <20140110.143927.1487756638081906180.davem@davemloft.net>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
	<1389314142-17969-2-git-send-email-pablo@netfilter.org>
	<52D05912.1030606@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <52D05912.1030606@cogentembedded.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 10 Jan 2014 23:33:22 +0300

> Hello.
> 
> On 01/10/2014 03:35 AM, Pablo Neira Ayuso wrote:
> 
>> net/netfilter/nft_reject.c: In function 'nft_reject_eval':
>> net/netfilter/nft_reject.c:37:14: warning: unused variable 'net'
>> [-Wunused-variable]
> 
>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
>> ---
>>   net/netfilter/nft_reject.c |    3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
> 
>> diff --git a/net/netfilter/nft_reject.c b/net/netfilter/nft_reject.c
>> index 0d690d4..7ae63cd 100644
>> --- a/net/netfilter/nft_reject.c
>> +++ b/net/netfilter/nft_reject.c
>> @@ -34,8 +34,9 @@ static void nft_reject_eval(const struct nft_expr
>> *expr,
>>   			      const struct nft_pktinfo *pkt)
>>   {
>>   	struct nft_reject *priv = nft_expr_priv(expr);
>> +#if IS_ENABLED(CONFIG_NF_TABLES_IPV6)
>>   	struct net *net = dev_net((pkt->in != NULL) ? pkt->in : pkt->out);
>> -
> 
>    Why remove empty line after the declaration block?

Because "#endif" sort of serves the same purpose.

This is what I do too in this situation.
