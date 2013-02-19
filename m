From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 7/7] netfilter: nf_ct_helper: better logging for dropped
 packets
Date: Mon, 18 Feb 2013 16:22:02 -0800
Message-ID: <1361233322.2046.3.camel@joe-AO722>
References: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
	 <1361232651-5626-8-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1361232651-5626-8-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-02-19 at 01:10 +0100, pablo@netfilter.org wrote:
> This patch modifies the existing code to provide more specific
> error message in the scope of each helper to help users to debug
> the reason why the packet has been dropped, ie:
[]
> diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
[]
> @@ -100,6 +100,9 @@ struct nf_ct_helper_expectfn {
>  	void (*expectfn)(struct nf_conn *ct, struct nf_conntrack_expect *exp);
>  };
>  
> +extern void nf_ct_helper_log(struct sk_buff *skb, const struct nf_conn *,
> +			     const char *fmt, ...);

this should be declared

__printf(3, 4)
void nf_ct_helper_log(etc...)

to get the compiler to verify format and arguments.

> @@ -210,8 +212,11 @@ static int help(struct sk_buff *skb, unsigned int protoff,
>  						 addr_beg_p - ib_ptr,
>  						 addr_end_p - addr_beg_p,
>  						 exp);
> -			else if (nf_ct_expect_related(exp) != 0)
> +			else if (nf_ct_expect_related(exp) != 0) {
> +				nf_ct_helper_log(skb, ct, "cannot add "
> +							  "expectation");

do please try to avoid splitting formats

				nf_ct_helper_log(skb, ct,
						 "cannot add expectation");

> @@ -1123,8 +1130,11 @@ static int process_sdp(struct sk_buff *skb, unsigned int protoff,
>  					      dptr, datalen, mediaoff,
>  					      SDP_HDR_CONNECTION, SDP_HDR_MEDIA,
>  					      &rtp_addr);
> -			if (ret != NF_ACCEPT)
> +			if (ret != NF_ACCEPT) {
> +				nf_ct_helper_log(skb, ct, "cannot mangle "
> +							  "media connection");

here too, etc...


