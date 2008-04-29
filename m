From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][NET_SCHED] sch_sfq: fix queue limiting while enqueuing
Date: Tue, 29 Apr 2008 22:53:41 +0200
Message-ID: <20080429205341.GA4356@ami.dom.local>
References: <20080427142216.GB7480@ami.dom.local> <4814C618.3050506@trash.net> <20080427203630.GA9648@ami.dom.local> <4815D8D9.5020201@trash.net> <20080428145837.GB2870@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:32615 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbYD2UvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 16:51:09 -0400
Received: by nf-out-0910.google.com with SMTP id d3so127677nfc.21
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 13:51:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080428145837.GB2870@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2008 at 04:58:37PM +0200, Jarek Poplawski wrote:
...
> Yes, a new parameter looks like the safest choice. I'll only have to
> re-think first the possible reason for this strange limit...

  
static inline void sfq_link(struct sfq_sched_data *q, sfq_index x)
{
	sfq_index p, n;
	int d = q->qs[x].qlen + SFQ_DEPTH;
-------------------->^^^^^^^^

	p = d;
	n = q->dep[d].next;
...

So it's really by design! (I don't know why I missed this, and why
it didn't break my lame test...)

Thanks again for stopping this disaster,
Jarek P. 
