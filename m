From: Patrick McHardy <kaber@trash.net>
Subject: Re: SFQ qdisc crashes with limit of 2 packets
Date: Wed, 19 Sep 2007 15:08:22 +0200
Message-ID: <46F11F46.8060108@trash.net>
References: <46F0087A.3080104@redhat.com> <46F00B80.7050901@trash.net> <46F0117A.4060807@trash.net> <46F023D0.7030307@trash.net> <20070919094803.GA17740@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <cebbert@redhat.com>, Netdev <netdev@vger.kernel.org>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63864 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754379AbXISNPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 09:15:23 -0400
In-Reply-To: <20070919094803.GA17740@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov wrote:
> Hello!
> 
>>CCed Alexey just to be safe, but I think the patch should be fine.
> 
> 
> Yes. But what'a about limit == 1? tc prohibits this case, but it is still
> not nice to have the bug in kernel. Plus, code remains creepy, the check
> 
> +	if (++sch->q.qlen < q->limit) {
> 
> still looks as a scary off-by-one. I would go all the way: replace this
> with natural:
> 
> 	if (++sch->q.qlen <= q->limit) {
> 
> and maxed q->limit at SFQ_DEPTH-2. Patch enclosed.


Thats even better, thanks :)
