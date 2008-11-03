From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2] sch_netem: Remove classful functionality
Date: Mon, 3 Nov 2008 08:29:26 +0000
Message-ID: <20081103082926.GA4698@ff.dom.local>
References: <20081031132010.GA18895@ff.dom.local> <20081102.003700.198708146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:5948 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754482AbYKCI3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 03:29:41 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1648079ugf.37
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2008 00:29:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081102.003700.198708146.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 02, 2008 at 12:37:00AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 31 Oct 2008 13:20:10 +0000
> 
> > Patrick McHardy noticed that: "a lot of the functionality of netem
> > requires the inner tfifo anyways and rate-limiting is usually done
> > on top of netem. So I would suggest so either hard-wire the tfifo
> > qdisc or at least make the assumption that inner qdiscs are
> > work-conserving.", and later: "- a lot of other qdiscs still don't
> > work as inner qdiscs of netem [...]".
> > 
> > So, according to his suggestion, this patch removes classful options
> > of netem. The main reason of this change is to remove ops->requeue()
> > method, which is currently used only by netem.
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Jarek, I applied this patch and your second one to net-next-2.6
> 
> But I did this only because I trust that you will address Stephen's
> feedback wrt. making existing netem functionality available in
> some way.
> 
> Otherwise I'll have to revert these changes.

Hmm... I thought there was kind of RFC for this, and it looked like
Patrick's idea won 100% of votes, but I'm not good in counting...

http://marc.info/?l=linux-netdev&m=122469801712438&w=2
http://marc.info/?l=linux-netdev&m=122469674709761&w=2

Anyway, IMHO adding TBF etc. functionalities to tfifo doesn't make
much sense, and if they are really needed it's better to revert
these patches and chose one of the other ways of doing reorder
proposed in this earlier thread.

Thanks,
Jarek P.
