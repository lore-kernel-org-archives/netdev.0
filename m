From: george anzinger <george@mvista.com>
Subject: Re: System crash in tcp_fragment()
Date: Tue, 21 May 2002 08:42:51 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <acdq3b$5m6$2@main.gmane.org>
References: <200205211247.QAA05603@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, niv@us.ibm.com, ak@suse.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> 
> Hello!
> 
> > I understand the issue.
> 
> I do not.
> 
> +#define preempt_disable() \
> +do { \
> +       ++current->preempt_count; \
> +       barrier(); \
> +} while (0)
> 
> Why does this work?
> 
> Alexey
Preemption can only happen if the task is interrupted.  The
interrupt exit code will not preempt if preempt_count is
more than zero.  The barrier() forces the result to memory
so the interrupt code can find it.
-- 
George Anzinger   george@mvista.com
High-res-timers: 
http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch:
http://www.kernel.org/pub/linux/kernel/people/rml
