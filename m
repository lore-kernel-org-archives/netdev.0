From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/7] sock_diag: Do not use RTA_PUT() macros
Date: Wed, 27 Jun 2012 06:07:43 -0400
Message-ID: <20120627100743.GE31808@canuck.infradead.org>
References: <aebb990d61eec6d97f1dfe52a0579981c40cce9e.1340788373.git.tgraf@suug.ch>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6F66@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:32952 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754512Ab2F0KHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 06:07:45 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F66@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 27, 2012 at 11:00:30AM +0100, David Laight wrote:
>  
> > @@ -35,9 +34,7 @@ EXPORT_SYMBOL_GPL(sock_diag_save_cookie);
> >  
> >  int sock_diag_put_meminfo(struct sock *sk, struct sk_buff 
> > *skb, int attrtype)
> >  {
> > -	__u32 *mem;
> > -
> > -	mem = RTA_DATA(__RTA_PUT(skb, attrtype, SK_MEMINFO_VARS *
> sizeof(__u32)));
> > +	u32 mem[SK_MEMINFO_VARS];
> 
> Isn't that likely to blow the kernel stack?

SK_MEMINFO_VARS = 8, so no. I can change it to use nla_reserve()
if wasting 32 bytes on the stack is an issue.
