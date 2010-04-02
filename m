From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rfs: Receive Flow Steering
Date: Fri, 02 Apr 2010 14:37:51 +0200
Message-ID: <1270211871.11099.2.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>
	 <1270197304.1936.179.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f217.google.com ([209.85.218.217]:51563 "EHLO
	mail-bw0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811Ab0DBMh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 08:37:57 -0400
Received: by bwz9 with SMTP id 9so1565165bwz.29
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 05:37:55 -0700 (PDT)
In-Reply-To: <1270197304.1936.179.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > +static inline void rps_record_sock_flow(struct rps_sock_flow_table *table,
> > +					u32 hash)
> > +{
> 
> Hmm, so rps_record_sock_flow() is always called from non preemptable
> contextes ?
> 
> > +	rps_set_sock_flow(table, hash, smp_processor_id());
> > +}
> > +

I had to change this to :

static inline void rps_record_sock_flow(struct rps_sock_flow_table *table, u32 hash)
{
	/* we only give a hint, preemption can change our cpu under us */
	rps_set_sock_flow(table, hash, raw_smp_processor_id());
}



