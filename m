From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 8/23] [PATCH] [XFRM] STATE: Add a hook to obtain local/remote
 outbound address.
Date: Sun, 30 Jul 2006 19:35:15 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607301932390.27032@d.namei>
References: <115416542536-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:31976 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932476AbWG3XfT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 19:35:19 -0400
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <115416542536-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 29 Jul 2006, Masahide NAKAMURA wrote:

> +			remote = (xfrm[i]->type->remote_addr) ?
> +				(struct in6_addr*)xfrm[i]->type->remote_addr(xfrm[i], (xfrm_address_t *)remote):
> +				(struct in6_addr*)&xfrm[i]->id.daddr;
> +			local  = (xfrm[i]->type->local_addr) ?
> +				(struct in6_addr*)xfrm[i]->type->local_addr(xfrm[i], (xfrm_address_t *)local):
> +				(struct in6_addr*)&xfrm[i]->props.saddr;

Again, it'd make the code so much cleaner to provide static inline 
wrappers for all of these types of:

	foo = op ? op->() : bar;
and

 	if (op)
		bar = op->();


-- 
James Morris
<jmorris@namei.org>
