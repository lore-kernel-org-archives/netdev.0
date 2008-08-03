From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Sun, 3 Aug 2008 12:08:50 +0200
Message-ID: <20080803100850.GA3077@ami.dom.local>
References: <20080802.121815.167998262.davem@davemloft.net> <20080802201944.GA14983@ami.dom.local> <20080803092926.GA2971@ami.dom.local> <20080803.025616.218557268.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:10961 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbYHCKIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 06:08:19 -0400
Received: by ug-out-1314.google.com with SMTP id h2so619367ugf.16
        for <netdev@vger.kernel.org>; Sun, 03 Aug 2008 03:08:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080803.025616.218557268.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 03, 2008 at 02:56:16AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 3 Aug 2008 11:29:26 +0200
> 
> > After some re-checking one more question: why do you think this
> > qdisc_root_lock() is safe as sch_tree_lock() (or anywhere else)? It
> > seems, eg. during deactivation it can get root_lock of qdisc_default,
> > and proceed with another qdisc?
> 
> We hold RTNL at the time.
> 
> If it's the default qdisc, that's fine, we'll reset it and free
> up the packets when the RCU handler of the qdisc_destroy() runs.
> 
> That's a case where locking the wrong qdisc is OK.

Right! Thanks again,

Jarek P.
