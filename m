From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] make tg3 NAPI support configurable
Date: Fri, 19 Dec 2003 14:20:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16354.64258.364153.488309@robur.slu.se>
References: <3FE2F3A7.2A109F28@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>,
        Linux Network Development list <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <3FE2F3A7.2A109F28@melbourne.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Greg Banks writes:

 > I've been having some issues with irq rates and cpu usage in the
 > tg3 driver.  In short, on Altix machines they're far too high.
 > It turned out that reverting the driver to its pre-NAPI interrupt
 > coalescing scheme made the situation a lot better.
 > 
 > How much better?  Running 8192 byte UDP packets across gige
 > with NAPI takes 99.5% of a CPU to service 29,100 irqs per second.
 > With the pre-NAPI code the figures are 36.0% CPU and 4880 irq/sec.
 > Similar improvements are seen for non-fragmented UDP and for TCP.

 Hello!

 You can use coalescing with NAPI as well, e1000 and other drivers
 are doing this. This will give you same interrupt rates as non-
 NAPI at low load and "polling" without any interrupts at high load.

 Furthermore NAPI can be extended to schedule dev->poll even for TX-
 interrupts. There is pacth for e1000 doing this. We see about 5-8% 
 overall system packet improvement with this.

 Cheers.
					--ro
