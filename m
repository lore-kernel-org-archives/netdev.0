From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v2 2/3] netpoll: add IPv6 support
Date: Thu, 03 Jan 2013 23:08:58 +0800
Message-ID: <1357225738.2505.4.camel@cr0>
References: <1357188623-15206-1-git-send-email-amwang@redhat.com>
	 <1357188623-15206-2-git-send-email-amwang@redhat.com>
	 <20130103.015453.730687035214069794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753035Ab3ACPJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2013 10:09:07 -0500
In-Reply-To: <20130103.015453.730687035214069794.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-03 at 01:54 -0800, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Thu,  3 Jan 2013 12:50:22 +0800
> 
> > -static inline int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh,
> > -				 int proto)
> > +int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
> >  {
> >  	int err;
> >  
> > -- 
> > 1.7.7.6
> > 
> 
> With IPV6=m and NETPOLL=y using this symbol will not work.
> 

Good point!

One solution is to introduce a new Kconfig option:

+config NETPOLL6
+       depends on (IPV6 || IPV6=n)
+       def_bool NETPOLL
+

and move these IPV6 code under #ifdef CONFIG_NETPOLL6.
