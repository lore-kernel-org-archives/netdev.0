From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] sch_netem: Remove classful functionality
Date: Fri, 31 Oct 2008 09:45:07 -0700
Message-ID: <20081031094507.09536b08@extreme>
References: <20081031132010.GA18895@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56433 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747AbYJaQpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 12:45:13 -0400
In-Reply-To: <20081031132010.GA18895@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 31 Oct 2008 13:20:10 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

> Patrick McHardy noticed that: "a lot of the functionality of netem
> requires the inner tfifo anyways and rate-limiting is usually done
> on top of netem. So I would suggest so either hard-wire the tfifo
> qdisc or at least make the assumption that inner qdiscs are
> work-conserving.", and later: "- a lot of other qdiscs still don't
> work as inner qdiscs of netem [...]".
> 
> So, according to his suggestion, this patch removes classful options
> of netem. The main reason of this change is to remove ops->requeue()
> method, which is currently used only by netem.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>

Okay, only if you add the following functionality back:
  * rate control, it doesn't have TBF, some other rate limiting
    is fine.

  * option for pure fifo or reordering based on jitter.

I have no problem with changing implementation as long as the same
feature set used by users remain.
