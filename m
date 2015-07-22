From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipv6: Avoid rt6_probe() taking writer lock in
 the fast path
Date: Wed, 22 Jul 2015 07:19:11 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507220716100.1851@ja.home.ssi.bg>
References: <1437522680-3515872-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:38306 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750934AbbGVETX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 00:19:23 -0400
In-Reply-To: <1437522680-3515872-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 21 Jul 2015, Martin KaFai Lau wrote:

> The patch checks neigh->nud_state before acquiring the writer lock.
> Note that rt6_probe() is only used in CONFIG_IPV6_ROUTER_PREF.

	Locking usage is absolutely correct.

> +		if (!(neigh->nud_state & NUD_VALID) &&
> +		    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {

	but this line is too long...

> +			work = kmalloc(sizeof(*work), GFP_ATOMIC);
> +			if (work) {
> +				__neigh_set_probe_once(neigh);
> +			}

	scripts/checkpatch.pl --strict /tmp/file.patch

Regards

--
Julian Anastasov <ja@ssi.bg>
