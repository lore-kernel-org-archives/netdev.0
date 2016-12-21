From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH RFC net-next 3/7] sctp: add dst_pending_confirm flag
Date: Wed, 21 Dec 2016 22:19:17 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1612212159240.1945@ja.home.ssi.bg>
References: <1482094596-26046-1-git-send-email-ja@ssi.bg> <1482094596-26046-4-git-send-email-ja@ssi.bg> <20161221141108.GB23197@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        YueHaibing <yuehaibing@huawei.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:50652 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756741AbcLUUTr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Dec 2016 15:19:47 -0500
In-Reply-To: <20161221141108.GB23197@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 21 Dec 2016, Neil Horman wrote:

> On Sun, Dec 18, 2016 at 10:56:32PM +0200, Julian Anastasov wrote:

> > -	tp->af_specific->sctp_xmit(head, tp);
> > +	confirm = tp->dst_pending_confirm;
> > +	if (confirm)
> > +		head->dst_pending_confirm = 1;
> Why not use your confirm helper function here?

	It is for sk, I can add a skb_set_dst_pending_confirm(skb,int)
helper, if needed.

> > +	if (!t->dst_pending_confirm)
> > +		t->dst_pending_confirm = 1;
> I'm not sure why you check it for being zero before setting it here, just set it
> unilaterally instead, or are you trying to avoid dirtying a cacheline?

	Yes, no other reason. I'll change it in the next version.

Regards
