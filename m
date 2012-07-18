From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/5] Long term PMTU/redirect storage in ipv4.
Date: Wed, 18 Jul 2012 09:30:48 +0200
Message-ID: <1342596648.2626.1831.camel@edumazet-glaptop>
References: <alpine.LFD.2.00.1207172249270.1831@ja.ssi.bg>
	 <20120717.134651.562831385960975623.davem@davemloft.net>
	 <alpine.LFD.2.00.1207180052420.2128@ja.ssi.bg>
	 <20120717.150920.1324071045620152376.davem@davemloft.net>
	 <alpine.LFD.2.00.1207180358190.2128@ja.ssi.bg>
	 <1342583166.2626.1367.camel@edumazet-glaptop>
	 <alpine.LFD.2.00.1207181014050.1652@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:44854 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244Ab2GRHax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 03:30:53 -0400
Received: by vcbfk26 with SMTP id fk26so886588vcb.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 00:30:53 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1207181014050.1652@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 10:28 +0300, Julian Anastasov wrote:

> 	This is going to read all values in the chain
> before reaching daddr? Or may be FNHE_RECLAIM_DEPTH is
> small and nobody will increase it. May be I can create
> some func that searches daddr in chain instead. Do you still
> prefer to remove the first daddr check or it is only
> that the code is intended too much?
> 

I would not bother, since real cost is the initial cache line miss.
Once you read one field, reading others is really fast.

> > +		if (fnhe_daddr == daddr) {
> 
> 	Also, do we need some rcu locking in
> __ip_rt_update_pmtu or may be ipv4_update_pmtu is
> called always under rcu lock?

Sorry, I dont understand, we use the full lock
write_seqlock_bh(&fnhe_seqlock);/write_sequnlock_bh(&fnhe_seqlock);
