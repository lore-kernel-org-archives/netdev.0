From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] netfilter: ip6t_SYNPROXY: fix NULL pointer
 dereference
Date: Sat, 8 Aug 2015 17:57:46 +0200
Message-ID: <20150808155746.GC29362@acer.localdomain>
References: <20150804175302.GA19650@salvia>
 <1438864497-3767-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60093 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964799AbbHHP5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Aug 2015 11:57:49 -0400
Content-Disposition: inline
In-Reply-To: <1438864497-3767-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.08, Phil Sutter wrote:
> This happens when networking namespaces are enabled.

Thanks, just one minor request:

>  synproxy_send_tcp(const struct sk_buff *skb, struct sk_buff *nskb,
>  		  struct nf_conntrack *nfct, enum ip_conntrack_info ctinfo,
>  		  struct ipv6hdr *niph, struct tcphdr *nth,
> -		  unsigned int tcp_hdr_size)
> +		  unsigned int tcp_hdr_size, struct synproxy_net *snet)

Logically the synproxy_net pointer should come before all other arguments
since its the container for a lot of the following arguments.
