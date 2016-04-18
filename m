From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH RFC net-next 0/2] pskb_extract() helper function.
Date: Mon, 18 Apr 2016 10:28:05 -0300
Message-ID: <20160418132805.GA5674@localhost.localdomain>
References: <cover.1460928360.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55266 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054AbcDRN2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2016 09:28:08 -0400
Content-Disposition: inline
In-Reply-To: <cover.1460928360.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2016 at 06:21:07AM -0700, Sowmini Varadhan wrote:
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
> 
> A further optimization is also possible by inlining pskb_trim()
> itself into pskb_carve() and thus avoiding the needless copy
> of trailer frags/pages that will then get trimmed away.  I am
> deferring that optimization  for the next iteration, and would
> like to get feedback on this first pass, which by itself gives
> a noticeable perf boost.

I like this idea. We can also make use of it in SCTP.

  Marcelo
