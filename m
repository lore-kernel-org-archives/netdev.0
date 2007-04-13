From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: TCP connection stops after high load.
Date: Fri, 13 Apr 2007 18:41:11 +0200
Message-ID: <20070413184111.0ab12e32.dada1@cosmosbay.com>
References: <461D2DEA.4010806@candelatech.com>
	<461D447C.4070408@candelatech.com>
	<20070411.134804.50594117.davem@davemloft.net>
	<461D4DD7.7020207@candelatech.com>
	<p73y7kx7iol.fsf@bingen.suse.de>
	<461E7377.3020708@candelatech.com>
	<20070412201940.7f570b6d.dada1@cosmosbay.com>
	<C8747F59-1852-4002-83C2-93883376AF15@mac.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	bcrl@kvack.org
To: Daniel Schaffrath <danielschaffrath@mac.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:52202 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754086AbXDMQlL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Apr 2007 12:41:11 -0400
In-Reply-To: <C8747F59-1852-4002-83C2-93883376AF15@mac.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Apr 2007 18:10:12 +0200
Daniel Schaffrath <danielschaffrath@mac.com> wrote:
> 
> On 2007/04/12  , at 20:19, Eric Dumazet wrote:
> >
> > Warning : tcpdump can lie, telling you packets being transmited  
> > several time.
> Maybe you have further pointers how come that tcpdump lies about  
> duplicated packets?
> 

dev_queue_xmit_nit() is called before attempting to send packet to device.

If device could not accept the packet (hard_start_xmit() returns an error), packet is requeued and retried later.
each retry means call ev_queue_xmit_nit() again, so tcpdump/sniffers can 'see' packet transmited several times. 

This is why I asked for "tc -s -d qdisc" results : to check the requeue counter (not its absolute value, but relative to number of packets sent)

See dev_hard_start_xmit() in net/core/dev.c

