From: kuznet@ms2.inr.ac.ru
Subject: Re: System crash in tcp_fragment()
Date: Tue, 21 May 2002 05:00:11 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <acc6aj$inp$2@main.gmane.org>
References: <20020520.173416.105610032.davem@redhat.com>
Mime-Version: 1.0
Cc: george@mvista.com, ak@suse.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20020520.173416.105610032.davem@redhat.com> from "David S. Miller" at May 20, 2 05:34:16 pm
List-Id: netdev.vger.kernel.org

Hello!

> Such rule does not even make this piece of code legal.  Consider:
> 
> task1:cpu0:	x = counters[smp_processor_id()];
>       cpu0:	PREEMPT
> task2:cpu0:	x = counters[smp_processor_id()];
> task2:cpu0:	counters[smp_processor_id()] = x + 1;
>       cpu0:	PREEMPT
> task1:cpu0:	counters[smp_processor_id()] = x + 1;
> 		full garbage

Yup. And this has nothing to do with SMP...


> But it does bring up important point, preemption people need to
> fully audit entire networking.

Well, we can make this. It is too serious. Anyway, this means that
preemptive patch for 2.4 is "tainting" :-)

Alexey
