From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] make tg3 NAPI support configurable
Date: Sat, 10 Jan 2004 20:49:46 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4000ABBA.50601@pobox.com>
References: <3FE2F3A7.2A109F28@melbourne.sgi.com> <16354.64258.364153.488309@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Banks <gnb@melbourne.sgi.com>, "David S. Miller" <davem@redhat.com>,
        Linux Network Development list <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16354.64258.364153.488309@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Greg Banks writes:
> 
>  > I've been having some issues with irq rates and cpu usage in the
>  > tg3 driver.  In short, on Altix machines they're far too high.
>  > It turned out that reverting the driver to its pre-NAPI interrupt
>  > coalescing scheme made the situation a lot better.
>  > 
>  > How much better?  Running 8192 byte UDP packets across gige
>  > with NAPI takes 99.5% of a CPU to service 29,100 irqs per second.
>  > With the pre-NAPI code the figures are 36.0% CPU and 4880 irq/sec.
>  > Similar improvements are seen for non-fragmented UDP and for TCP.
> 
>  Hello!
> 
>  You can use coalescing with NAPI as well, e1000 and other drivers
>  are doing this. This will give you same interrupt rates as non-
>  NAPI at low load and "polling" without any interrupts at high load.

Yes, this is something I've been meaning to add to tg3 for months now. 
Adding some about of hardware intr mitigation -in addition to- NAPI will 
not only help on the NAPI "hard case" of moderate load and a super-fast 
CPU, but also help avoid certain silicon bugs...


>  Furthermore NAPI can be extended to schedule dev->poll even for TX-
>  interrupts. There is pacth for e1000 doing this. We see about 5-8% 
>  overall system packet improvement with this.

tg3 already schedules for TX, so we've got that part covered :)

	Jeff
