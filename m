From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH V3] neigh: Really delete an arp/neigh entry on "ip neigh
 delete" or "arp -d"
Date: Wed, 31 May 2017 17:46:39 -0400
Message-ID: <20170531214639.GH9362@oracle.com>
References: <1496188346-83229-1-git-send-email-sowmini.varadhan@oracle.com>
 <alpine.LFD.2.20.1705312337280.5775@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        stephen@networkplumber.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42073 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbdEaVq7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 17:46:59 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1705312337280.5775@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (06/01/17 00:41), Julian Anastasov wrote:
> 
> 	So, we do not hold reference to neigh while accessing
> its fields. I suspect we need to move the table lock from
> neigh_remove_one here, for example:

good point, let me think over your suggestion carefully (it sounds
right, I want to make sure I dont miss any other race-windows)
and post patch v4 tomorrow..

> 	Another solution to cause faster removal would be
> to cancel the gc_work and to schedule it after 1 jiffie.
> It helps when many entries are deleted at once but the
> work prefers to just sleep when gc_thresh1 is not reached,
> so such solution is not good enough.

Right the other drawback of relying on gc for cleanup is
that it doesn't give higher preference to cleaning up FAILED
entries first- so it can end up cleaning up other useful entries
(as I was pointing out to David Ahern)

--Sowmini
