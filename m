From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH 3/5] netfilter: add SYNPROXY core/target
Date: Thu, 8 Aug 2013 17:07:10 +0200
Message-ID: <20130808170710.28394af9@redhat.com>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
	<1375897371-18430-4-git-send-email-kaber@trash.net>
	<20130807222600.51eeca09@redhat.com>
	<20130807205602.GA21463@macbook.localnet>
	<20130808062255.GB24450@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, as@one.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24999 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965689Ab3HHPHV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 11:07:21 -0400
In-Reply-To: <20130808062255.GB24450@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Aug 2013 08:22:55 +0200
Patrick McHardy <kaber@trash.net> wrote:

> On Wed, Aug 07, 2013 at 10:56:03PM +0200, Patrick McHardy wrote:
> > On Wed, Aug 07, 2013 at 10:26:00PM +0200, Jesper Dangaard Brouer wrote:
> > > On Wed,  7 Aug 2013 19:42:49 +0200
> > > Patrick McHardy <kaber@trash.net> wrote:
> > > 
> > > Besides when using net->proc_net_stat, then the first entry is usually
> > > "entries" which is not percpu, this will likely confusing the tool:
> > >   lnstat -f synproxy -c 42
> > 
> > I'll look into that.
> 
> Ok right, the first field must contains something that is not per-CPU.
> Unfortunately I don't have anything to put there and I really don't want
> to keep any global state. The two possibilities I see are:
> 
> - a dummy field
> - the number of proxied connections, but not using a global counter but
>   gathered by iterating over the entire conntrack hash.
> 
> Any opinions?

Well, I would of cause be nice to have some "entries" counter, e.g.
listing the number of active conntrack entries created by the SYNPROXY
target, but I don't think it's possible to identify those conntrack
entries, right.
So, I think it would be okay with just a dummy "entries" field which is
always zero.  

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
