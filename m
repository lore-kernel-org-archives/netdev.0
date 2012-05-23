From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 16/17] netfilter: add namespace support for cttimeout
Date: Wed, 23 May 2012 12:41:10 +0200
Message-ID: <20120523104110.GF2836@1984>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1336985547-31960-17-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1336985547-31960-17-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 04:52:26PM +0800, Gao feng wrote:
> add struct net as a param of ctnl_timeout.nlattr_to_obj,
> 
> modify ctnl_timeout_parse_policy and cttimeout_new_timeout
> to transmit struct net to nlattr_to_obj.

Please, merge your patch 16 and 17 into one single patch.

>  	unsigned int *timeouts = data;
>  
> diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
> index 291cef4..a28f3c4 100644
> --- a/net/netfilter/nf_conntrack_proto_sctp.c
> +++ b/net/netfilter/nf_conntrack_proto_sctp.c
> @@ -562,7 +562,8 @@ static int sctp_nlattr_size(void)
>  #include <linux/netfilter/nfnetlink.h>
>  #include <linux/netfilter/nfnetlink_cttimeout.h>
>  
> -static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
> +static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[],
> +				      struct net *net, void *data)

The interface modification and the use of the new *net parameter
should go together, ie. merge patch 16 and 17 :-).
