From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 02/02] add mask options to fwmark masking code
Date: Mon, 20 Feb 2006 17:57:11 +0100
Message-ID: <43F9F4E7.5000708@trash.net>
References: <23140.1140452813@sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netfilter-devel <netfilter-devel@lists.netfilter.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Michael Richardson <mcr@xelerance.com>
In-Reply-To: <23140.1140452813@sandelman.ottawa.on.ca>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Michael Richardson wrote:
> [PATCH] This patch introduces a mask to the fwmark test cases in the advanced
> routing. This let's one test individual bits of the fwmark to determine
> how things should be routed (pick a routing table). This patch retains
> compatibility with tests that do not set the mask by assuming a mask
> of 0 is equivalent to a mask of 0xffffffff.


> bcdda64a16d4dfda6d95452bbf8541999121831a
> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index 27fd17e..a5b55c2 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
> @@ -266,6 +266,7 @@ enum rtattr_type_t
>  };
>  
>  #define RTA_FWMARK      RTA_PROTOINFO
> +#define RTA_FWMARK_MASK RTA_CACHEINFO

Please introduce a new attribute for this instead of overloading
RTA_CACHEINFO.

> diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
> index de327b3..69eed89 100644
> --- a/net/ipv4/fib_rules.c
> +++ b/net/ipv4/fib_rules.c
> @@ -68,6 +68,7 @@ struct fib_rule
>  	u8		r_tos;
>  #ifdef CONFIG_IP_ROUTE_FWMARK
>  	u32		r_fwmark;
> +        u32             r_fwmark_mask;

Both patches have whitespace issues. You should also change decnet,
which also supports routing by fwmark. Other than that the patch
looks fine, in fact its nearly identical to a patch I wanted to
send soon which does the same :)
