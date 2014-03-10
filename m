From: Stanislav Meduna <stano@meduna.org>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1) instead
 of yield() to wait for outstanding qdisc_run calls
Date: Mon, 10 Mar 2014 01:07:10 +0100
Message-ID: <531D022E.4070009@meduna.org>
References: <1393976987-23555-1-git-send-email-mkl@pengutronix.de>	<20140306.160622.59358366688518505.davem@davemloft.net>	<1394392160.15968.13.camel@deadeye.wl.decadent.org.uk> <20140309.185338.2057082497431220324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, linux-rt-users@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: David Miller <davem@davemloft.net>, ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140309.185338.2057082497431220324.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09.03.2014 23:53, David Miller wrote:

> To me it means "I've got nothing to do if other tasks want to run right
> now"  Yes, I even see it having this meaning when an RT task executes
> it.

http://www.kernel.org/doc/htmldocs/device-drivers/API-yield.html
lists this exact "while (!event) yield;" pattern as a broken usage
and states "Never use yield as a progress guarantee!!".

> How else can you interpret the intent above?

IMNSHO there is no way to make the yield() honor this intent if it is
called from a SCHED_FIFO or SCHED_RR task and the task unblocking
it is running at a lower priority. On the PREEMPT_RT systems where
the interrupt handlers are threads an application thread running
at higher priority than some interrupt handlers is a common situation.

The semantics of the scheduler here is "run the highest priority
runnable task until it blocks (FIFO) or its time slice is over
and there are more with the _same_ priority (RR)". This scenario
then collapses into a busy loop never making progress.

> If you change it to msleep(1), you're assigning an extra completely
> arbitrary time limit to the yield.  The code doesn't want to sleep
> for 1ms, that's not what it's asking for.

The problem is that there is no way to formulate what it is asking
for in scheduler terms only.

Regards
-- 
                                     Stano
