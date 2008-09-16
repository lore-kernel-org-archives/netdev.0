From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: LRO num of frags limit
Date: Tue, 16 Sep 2008 18:25:34 +0300
Message-ID: <20080916152534.GA28609@mtls03>
References: <20080916073632.GA25226@mtls03> <1221561617.3244.78.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, themann@de.ibm.com,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:35147 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752190AbYIPPY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 11:24:28 -0400
Content-Disposition: inline
In-Reply-To: <1221561617.3244.78.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2008 at 11:40:17AM +0100, Ben Hutchings wrote:
> On Tue, 2008-09-16 at 10:36 +0300, Eli Cohen wrote:
> > Hi,
> > 
> > looking at the LRO code, at __lro_proc_segment(), it seems that the
> > network driver can configure lro_mgr->max_aggr to any value it wants
> > while the number of fragments aggregated must not exceed MAX_SKB_FRAGS
> 
> Correct.
> 
> > (since we only use a single SKB to aggregate fragments, allocated by
> > lro_gen_skb()). Moreover, even if the driver does limit
> > lro_mgr->max_aggr to MAX_SKB_FRAGS, it might still cause overflow
> > since subsequent aggregations are done at lro_add_frags() which is
> > called before checking whether we overflow.
> 
> So you must set max_aggr to
> MAX_SKB_FRAGS - max number of frags added at once + 1.
> 
> > If the above observation is correct, I can send a patch.
> 
> I would be interested to see that, anyway.
> 
By the way, we need to introduce two kinds of "max_aggr" fields to
struct net_lro_mgr. The reason is that when LRO is used in the mode in
which SKBs are linked, the above limitation does not exist. One will
be used for drivers which use lro_receive_skb() (which does not have a
limit) and one for drivers which use lro_receive_frags(). This will
require changing all the drivers that use LRO.
