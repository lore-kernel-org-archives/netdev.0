From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Drops in qdisc on ifb interface
Date: Mon, 25 May 2015 20:17:26 -0700
Message-ID: <1432610246.4060.220.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432584300.32671.103.camel@jasiiieee.pacifera.com>
	 <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432608770.32671.122.camel@jasiiieee.pacifera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35490 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbbEZDR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 23:17:28 -0400
Received: by pacwv17 with SMTP id wv17so82100421pac.2
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 20:17:28 -0700 (PDT)
In-Reply-To: <1432608770.32671.122.camel@jasiiieee.pacifera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-25 at 22:52 -0400, John A. Sullivan III wrote:

> Hmm . . . I've been thinking about that SFQ leaf qdisc.  I see that
> newer kernels allow a much higher "limit" than 127 but it still seems
> that the queue depth limit for any one flow is still 127.  When we do
> something like GRE/IPSec, I think the decrypted GRE traffic will
> distribute across the queues but the IPSec traffic will collapse all the
> packets initially into one queue.  At 80ms RTT a 1 Gbps wire speed, I
> would need a queue of around 7500.  Thus, can one say that SFQ is almost
> useless for high BDP connections?

I am a bit surprised, as your 'nstat' output showed no packet
retransmits. So no packets were lost in your sfq.

> 
> Is there a similar round-robin type qdisc that does not have this
> limitation?

fq_codel limit 10000 

> 
> If I recall correctly, if one does not attach a qdisc explicitly to a
> class, it defaults to pfifo_fast.  Is that correct? Thanks - John
> 

That would be pfifo.

pfifo_fast is the default root qdisc ( /proc/sys/net/core/default_qdisc
)
