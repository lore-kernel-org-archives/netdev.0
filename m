From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 4/6v2] netfilter: replace uses of NIP6_FMT with %p6
Date: Tue, 28 Oct 2008 15:42:36 -0700
Message-ID: <1225233757.5269.211.camel@localhost>
References: <1225223641.11483.42.camel@brick>
	 <1225224815.11483.56.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3217 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812AbYJ1Wml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 18:42:41 -0400
In-Reply-To: <1225224815.11483.56.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-10-28 at 13:13 -0700, Harvey Harrison wrote:
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> diff --git a/net/netfilter/nf_conntrack_ftp.c
> b/net/netfilter/nf_conntrack_ftp.c
> index 4f71071..a90d463 100644
> --- a/net/netfilter/nf_conntrack_ftp.c
> +++ b/net/netfilter/nf_conntrack_ftp.c
> @@ -467,11 +467,9 @@ static int help(struct sk_buff *skb,
>  				 NIPQUAD(cmd.u3.ip),
>  				 NIPQUAD(ct->tuplehash[dir].tuple.src.u3.ip));
>  		} else {
> -			pr_debug("conntrack_ftp: NOT RECORDING: " NIP6_FMT
> -				 " != " NIP6_FMT "\n",
> -				 NIP6(*((struct in6_addr *)cmd.u3.ip6)),
> -				 NIP6(*((struct in6_addr *)
> -					ct->tuplehash[dir].tuple.src.u3.ip6)));
> +			pr_debug("conntrack_ftp: NOT RECORDING: %p6 != %p6\n",
> +				 cmd.u3.ip6, 
> +				 ct->tuplehash[dir].tuple.src.u3.ip6);
>  		}

I think it's better to change all uses of:
  (foo.<ie: ct->tuplehash[dir].tuple.src.>)u3.ip6
to:
  &foo.u3.in6

as the union defines a struct in6_addr and not use the
ip6 array which is __be32[4].

