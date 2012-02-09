From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: nf_queue: fix queueing of bridged gro
 skbs
Date: Thu, 9 Feb 2012 16:44:21 +0100
Message-ID: <20120209154421.GA5865@1984>
References: <1328530990-6782-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44886 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752828Ab2BIPoY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 10:44:24 -0500
Content-Disposition: inline
In-Reply-To: <1328530990-6782-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Mon, Feb 06, 2012 at 01:23:10PM +0100, Florian Westphal wrote:
> When trying to nf_queue GRO/GSO skbs, nf_queue uses skb_gso_segment
> to split the skb.
> 
> However, if nf_queue is called via bridge netfilter, the mac header
> won't be preserved -- packets will thus contain a bogus mac header.
> 
> Fix this by setting skb->data to the mac header when skb->nf_bridge
> is set and restoring skb->data afterwards for all segments.

Better fix skb_gso_segment to handle this case?
