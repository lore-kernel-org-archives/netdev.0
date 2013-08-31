From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v11 01/11] ipv6: move ip6_dst_hoplimit() into
 core kernel
Date: Sat, 31 Aug 2013 13:07:34 +0800
Message-ID: <1377925654.29366.1.camel@cr0>
References: <1377918448-29888-1-git-send-email-amwang@redhat.com>
	 <1377918448-29888-2-git-send-email-amwang@redhat.com>
	 <20130831.005925.168719024280186075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19948 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754358Ab3HaFHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Aug 2013 01:07:42 -0400
In-Reply-To: <20130831.005925.168719024280186075.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-31 at 00:59 -0400, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Sat, 31 Aug 2013 11:07:18 +0800
> 
> > @@ -75,3 +76,24 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
> >  	return offset;
> >  }
> >  EXPORT_SYMBOL(ip6_find_1stfragopt);
> > +
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +int ip6_dst_hoplimit(struct dst_entry *dst)
>  ...
> > +#endif
> > +EXPORT_SYMBOL(ip6_dst_hoplimit);
> 
> I don't think the export should be outside of the #if region.
> 
> Did you test the build with IPV6 disabled?

Yes, but it didn't show me any error.

Below is my 3 config's for IPV6:

% grep IPV6 .config_ipv6_*
.config_ipv6_m:CONFIG_IPV6=m
.config_ipv6_m:CONFIG_IPV6_PRIVACY=y
.config_ipv6_m:CONFIG_IPV6_ROUTER_PREF=y
.config_ipv6_m:CONFIG_IPV6_ROUTE_INFO=y
.config_ipv6_m:CONFIG_IPV6_OPTIMISTIC_DAD=y
.config_ipv6_m:CONFIG_IPV6_MIP6=m
.config_ipv6_m:CONFIG_IPV6_SIT=m
.config_ipv6_m:CONFIG_IPV6_SIT_6RD=y
.config_ipv6_m:CONFIG_IPV6_NDISC_NODETYPE=y
.config_ipv6_m:CONFIG_IPV6_TUNNEL=m
.config_ipv6_m:CONFIG_IPV6_GRE=m
.config_ipv6_m:CONFIG_IPV6_MULTIPLE_TABLES=y
.config_ipv6_m:CONFIG_IPV6_SUBTREES=y
.config_ipv6_m:CONFIG_IPV6_MROUTE=y
.config_ipv6_m:CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
.config_ipv6_m:CONFIG_IPV6_PIMSM_V2=y
.config_ipv6_m:CONFIG_NF_DEFRAG_IPV6=m
.config_ipv6_m:CONFIG_NF_CONNTRACK_IPV6=m
.config_ipv6_m:CONFIG_IP6_NF_MATCH_IPV6HEADER=m
.config_ipv6_m:CONFIG_NF_NAT_IPV6=m
.config_ipv6_n:# CONFIG_IPV6 is not set
.config_ipv6_y:CONFIG_IPV6=y
.config_ipv6_y:CONFIG_IPV6_PRIVACY=y
.config_ipv6_y:CONFIG_IPV6_ROUTER_PREF=y
.config_ipv6_y:CONFIG_IPV6_ROUTE_INFO=y
.config_ipv6_y:CONFIG_IPV6_OPTIMISTIC_DAD=y
.config_ipv6_y:CONFIG_IPV6_MIP6=y
.config_ipv6_y:CONFIG_IPV6_SIT=y
.config_ipv6_y:CONFIG_IPV6_SIT_6RD=y
.config_ipv6_y:CONFIG_IPV6_NDISC_NODETYPE=y
.config_ipv6_y:CONFIG_IPV6_TUNNEL=y
.config_ipv6_y:CONFIG_IPV6_GRE=y
.config_ipv6_y:CONFIG_IPV6_MULTIPLE_TABLES=y
.config_ipv6_y:CONFIG_IPV6_SUBTREES=y
.config_ipv6_y:CONFIG_IPV6_MROUTE=y
.config_ipv6_y:CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
.config_ipv6_y:CONFIG_IPV6_PIMSM_V2=y
.config_ipv6_y:# CONFIG_IP_VS_IPV6 is not set
.config_ipv6_y:# CONFIG_NF_DEFRAG_IPV6 is not set
.config_ipv6_y:# CONFIG_NF_CONNTRACK_IPV6 is not set
