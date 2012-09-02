From: Sami Farin <hvtaifwkbgefbaei@gmail.com>
Subject: Re: (ipt_log_packet, sb_add) 3.6.0-rc2 kernel panic - not syncing;
 Fatal exception in interrupt
Date: Sun, 2 Sep 2012 16:45:56 +0300
Message-ID: <20120902134555.clpvegu4oirikwpn@m.safari.iki.fi>
References: <20120821134921.behn76vzvhczf3gc@m.safari.iki.fi>
 <20120902122008.jgdhwowbuke6by7h@m.safari.iki.fi>
 <20120902132834.GB7456@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sami Farin <hvtaifwkbgefbaei@gmail.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kponet.fi ([213.145.209.38]:47407 "EHLO smtp.kponet.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752762Ab2IBNp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Sep 2012 09:45:57 -0400
Received: from safari.iki.fi (unknown [77.223.43.54])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.kponet.fi (Postfix) with ESMTP id 6B23CDAE31
	for <netdev@vger.kernel.org>; Sun,  2 Sep 2012 16:45:56 +0300 (EEST)
Content-Disposition: inline
In-Reply-To: <20120902132834.GB7456@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 02, 2012 at 15:28:34 +0200, Florian Westphal wrote:
> Sami Farin <hvtaifwkbgefbaei@gmail.com> wrote:
> > I get this panic every 1-2 days.
> > Also with 7a611e69b26069a511d9d5251c6a28af6c521121 (commit before 3.6.0-rc4).
> 
> Could you please post iptables-save output?
> My guess is you're using NFLOG in INPUT?

I don't have NFLOG but I have some like this
-j LOG --log-tcp-options --log-ip-options --log-uid --log-macdecode
I also have CONFIG_IP_ROUTE_CLASSID=y , using also htb + fq_codel.

using these ipt* modules
ipt_ECN                 1849  1 
ipt_REJECT              2661  12 
iptable_filter          1650  1 
iptable_mangle          1631  1 
iptable_raw             1422  1 
ip_tables              17482  3 iptable_filter,iptable_mangle,iptable_raw
x_tables               20149  26 ip6table_filter,arp_tables,ip6table_mangle,xt_length,ip_tables,xt_tcpudp,arptable_filter,xt_limit,xt_owner,xt_state,xt_connlimit,xt_conntrack,xt_NOTRACK,xt_LOG,xt_set,xt_hashlimit,xt_multiport,iptable_filter,xt_CLASSIFY,ip6t_rt,xt_connmark,ipt_REJECT,iptable_mangle,ipt_ECN,ip6_tables,iptable_raw

> If so, I bet its caused by the tcp early demux stuff.
> Does that crash go away with ip_early_demux sysctl off?

I try that, thanks!
 
> My guess is its assigning skb->sk with TIMEWAIT sockets, which
> would explain the crash.

-- 
Do what you love because life is too short for anything else.
