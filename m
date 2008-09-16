From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: LRO num of frags limit
Date: Tue, 16 Sep 2008 11:40:17 +0100
Message-ID: <1221561617.3244.78.camel@achroite>
References: <20080916073632.GA25226@mtls03>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, themann@de.ibm.com,
	linux-kernel@vger.kernel.org
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:60260 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751745AbYIPKkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 06:40:24 -0400
In-Reply-To: <20080916073632.GA25226@mtls03>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-09-16 at 10:36 +0300, Eli Cohen wrote:
> Hi,
> 
> looking at the LRO code, at __lro_proc_segment(), it seems that the
> network driver can configure lro_mgr->max_aggr to any value it wants
> while the number of fragments aggregated must not exceed MAX_SKB_FRAGS

Correct.

> (since we only use a single SKB to aggregate fragments, allocated by
> lro_gen_skb()). Moreover, even if the driver does limit
> lro_mgr->max_aggr to MAX_SKB_FRAGS, it might still cause overflow
> since subsequent aggregations are done at lro_add_frags() which is
> called before checking whether we overflow.

So you must set max_aggr to
MAX_SKB_FRAGS - max number of frags added at once + 1.

> If the above observation is correct, I can send a patch.

I would be interested to see that, anyway.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

