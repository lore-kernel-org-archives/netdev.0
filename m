From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH V3] neigh: Really delete an arp/neigh entry on "ip neigh
 delete" or "arp -d"
Date: Wed, 31 May 2017 21:21:04 -0400
Message-ID: <20170601012104.GA23011@oracle.com>
References: <1496188346-83229-1-git-send-email-sowmini.varadhan@oracle.com>
 <alpine.LFD.2.20.1705312337280.5775@ja.home.ssi.bg>
 <20170531214639.GH9362@oracle.com>
 <alpine.LFD.2.20.1706010059370.10214@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        stephen@networkplumber.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22758 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750954AbdFABVX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 21:21:23 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1706010059370.10214@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (06/01/17 01:41), Julian Anastasov wrote:
> 	Another problem is that neigh_update() changes the
> state but before we go and unlink the entry another CPU
> can reactivate the entry, i.e. NUD_INCOMPLETE entered
> in __neigh_event_send(). So, there will be always some
> small window where surprises can happen and the entry is
> not really deleted.

but that would be ok- it's the same as if I did
   arp -d <addr>
   ping <addr>

I think the only danger is that, once we drop the ref with
neigh_release(), we are relying on the table's lock for the neigh
to not disappear under us. Thus as you correctly pointed out,
we need the tbl->lock to make sure we sync with all paths that
can pull the neigh out of the table (and release the table's ref
along the way).

Thanks for catching that, patch v4 (with correct smtp timestamp!)
will be sent out shortly.

--Sowmini
