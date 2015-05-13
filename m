From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 5/5] netfilter: add netfilter ingress hook after
 handle_ing() under unique static key
Date: Wed, 13 May 2015 19:56:59 +0200
Message-ID: <20150513175659.GA27999@salvia>
References: <1431533978-26901-1-git-send-email-pablo@netfilter.org>
 <1431533978-26901-6-git-send-email-pablo@netfilter.org>
 <55538302.5080702@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com, daniel@iogearbox.net,
	eric.dumazet@gmail.com, kaber@trash.net
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53334 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751921AbbEMRwS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 13:52:18 -0400
Content-Disposition: inline
In-Reply-To: <55538302.5080702@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 09:59:46AM -0700, Alexei Starovoitov wrote:
> On 5/13/15 9:19 AM, Pablo Neira Ayuso wrote:
> >This patch adds the Netfilter ingress hook just after the existing tc ingress
> >hook, that seems to be the consensus solution for this.
> 
> Looks good to me.
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
> 
> >diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> >index 2b39235..6c256f8 100644
> >--- a/include/linux/netdevice.h
> >+++ b/include/linux/netdevice.h
> >@@ -1659,6 +1659,9 @@ struct net_device {
> >  	struct tcf_proto __rcu  *ingress_cl_list;
> >  #endif
> >  	struct netdev_queue __rcu *ingress_queue;
> >+#ifdef CONFIG_NETFILTER_INGRESS
> >+	struct list_head	nf_hooks_ingress;
> >+#endif
> ...
> >diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
> >index f70e34a..db1c674 100644
> >--- a/net/netfilter/Kconfig
> >+++ b/net/netfilter/Kconfig
> >@@ -1,6 +1,13 @@
> >  menu "Core Netfilter Configuration"
> >  	depends on NET && INET && NETFILTER
> >
> >+config NETFILTER_INGRESS
> >+	bool "Netfilter ingress support"
> >+	select NET_INGRESS
> >+	help
> >+	  This allows you to classify packets from ingress using the Netfilter
> >+	  infrastructure.
> >+
> 
> should be some default hint as well?
> not sure why you want to do it under another config flag.
> Just makes it harder to test all config combinations.
> I think under global CONFIG_NETFILTER it would be fine as well.

Yes, that default can be added there. And I agree, since this depends
on CONFIG_NETFILTER should be fine. I have more patches following up,
I can queue one small for this.

Thanks.
