From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 6/7] net/netfilter/nfnetlink_log.c: fix error return
 code
Date: Thu, 30 Aug 2012 03:35:33 +0200
Message-ID: <20120830013533.GE8878@1984>
References: <1346258957-7649-1-git-send-email-Julia.Lawall@lip6.fr>
 <1346258957-7649-8-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44037 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754230Ab2H3Bfg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2012 21:35:36 -0400
Content-Disposition: inline
In-Reply-To: <1346258957-7649-8-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 29, 2012 at 06:49:17PM +0200, Julia Lawall wrote:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Initialize return variable before exiting on an error path.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> (
> if@p1 (\(ret < 0\|ret != 0\))
>  { ... return ret; }
> |
> ret@p1 = 0
> )
> ... when != ret = e1
>     when != &ret
> *if(...)
> {
>   ... when != ret = e2
>       when forall
>  return ret;
> }
> 
> // </smpl>

And also applied, thanks Julia. I'll pass these to current -rc.
