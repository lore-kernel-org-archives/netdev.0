From: marcelo.leitner@gmail.com
Subject: Re: [PATCH net-next 0/2] pskb_extract() helper function.
Date: Fri, 22 Apr 2016 20:23:01 -0300
Message-ID: <20160422232301.GA1594@localhost.localdomain>
References: <cover.1461086306.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	santosh.shilimkar@oracle.com, davem@davemloft.net,
	eric.dumazet@gmail.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48268 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753360AbcDVXXG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 19:23:06 -0400
Content-Disposition: inline
In-Reply-To: <cover.1461086306.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2016 at 03:17:40AM -0700, Sowmini Varadhan wrote:
> This patchset follows up on the discussion in
>  https://www.mail-archive.com/netdev@vger.kernel.org/msg105090.html
> 
> For RDS-TCP, we have to deal with the full gamut of
> nonlinear sk_buffs, including all the frag_list variants.
> Also, the parent skb has to remain unchanged, while the clone
> is queued for Rx on the PF_RDS socket. 
> 
> Patch 1 of this patchset adds a pskb_extract() function that 
> does all this without the redundant memcpy's in pskb_expand_head() 
> and __pskb_pull_tail().

I applied this patchset and updated SCTP to also use it for data chunks.

My tests results were very similar to what I had without it. Varying to
better or worse, tending worse.  Thing is, SCTP always works on
linearized skbs as it can't crawl on fragments, so those clone/trim
operations are just offset adjusts regarding the data, and it's shared.
With pskb_extract, it implies in a new memory allocation and a copy,
even in this best case, so for SCTP, for now, it's actually a drawback
I'm afraid.

  Marcelo
