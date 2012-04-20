From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH net-next 01/19] net: Implement register_net_sysctl.
Date: Fri, 20 Apr 2012 09:27:07 +0400
Message-ID: <4F90F3AB.7050600@parallels.com>
References: <m1aa27ia6h.fsf@fess.ebiederm.org> <m162cvia3s.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7599 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750758Ab2DTF1W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 01:27:22 -0400
In-Reply-To: <m162cvia3s.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -117,6 +117,13 @@ struct ctl_table_header *register_net_sysctl_rotable(const
>  }
>  EXPORT_SYMBOL_GPL(register_net_sysctl_rotable);
>  
> +struct ctl_table_header *register_net_sysctl(struct net *net,
> +	const char *path, struct ctl_table *table)
> +{
> +	return __register_sysctl_table(&net->sysctls, path, table);

Eric, am I right, that after this all sysctl-s registered in init_net will
not be even visible in the non-init net namespaces?

If I'm not mistaken, before this all non-virtualized, i.e. "global" sysctls
were read-only in sub net namespaces and that solved lots of problems for us.

> +}
> +EXPORT_SYMBOL_GPL(register_net_sysctl);
> +
>  void unregister_net_sysctl_table(struct ctl_table_header *header)
>  {
>  	unregister_sysctl_table(header);
