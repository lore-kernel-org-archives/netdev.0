From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: System crash in tcp_fragment()
Date: Mon, 20 May 2002 18:49:27 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <acc972$mp1$2@main.gmane.org>
References: <20020520.173416.105610032.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <kuznet@ms2.inr.ac.ru>, <george@mvista.com>, <ak@suse.de>,
   <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>, <ak@muc.de>,
   <pekkas@netcore.fi>
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020520.173416.105610032.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Mon, 20 May 2002, David S. Miller wrote:

> Such rule does not even make this piece of code legal.  Consider:
> 
> task1:cpu0:	x = counters[smp_processor_id()];
>       cpu0:	PREEMPT
> task2:cpu0:	x = counters[smp_processor_id()];
> task2:cpu0:	counters[smp_processor_id()] = x + 1;
>       cpu0:	PREEMPT
> task1:cpu0:	counters[smp_processor_id()] = x + 1;
> 		full garbage
> 
> But it does bring up important point, preemption people need to
> fully audit entire networking.
> 
> It is totally broken by preemption the more I think about it.
> 
> At the very beginning, all the SNMP counter bumping tricks will
> totally fail with preemption enabled.
> 

A lot of the synchronization between process context and interrupt
context is based on per-cpu data structures or simple locks
(without disabling irq's globally) eg:

softnet_data queue (we only disable local interrupts), and
synchronization between tcp_readmsg() and tcp_rcv() over
the receive queue would get confused (lock.users flag would
be different on another CPU)..

Wonder how any of it could possibly work..

thanks,
Nivedita
