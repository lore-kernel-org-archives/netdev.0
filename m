From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2 1/9] net: core: use this_cpu_ptr per-cpu helper
Date: Sat, 3 Nov 2012 09:20:47 +0100
Message-ID: <20121103082047.GA20868@secunet.com>
References: <5093EE47.20700@gmail.com>
 <0000013ac239c004-87f4c3e0-5c6a-4979-817f-0a0c4445a4e9-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shan Wei <shanwei88@gmail.com>, David Miller <davem@davemloft.net>,
	timo.teras@iki.fi, NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0000013ac239c004-87f4c3e0-5c6a-4979-817f-0a0c4445a4e9-000000@email.amazonses.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 02, 2012 at 05:44:55PM +0000, Christoph Lameter wrote:
> On Sat, 3 Nov 2012, Shan Wei wrote:
> > +++ b/net/core/flow.c
> > @@ -327,11 +327,9 @@ static void flow_cache_flush_tasklet(unsigned long data)
> >  static void flow_cache_flush_per_cpu(void *data)
> >  {
> >  	struct flow_flush_info *info = data;
> > -	int cpu;
> >  	struct tasklet_struct *tasklet;
> >
> > -	cpu = smp_processor_id();
> > -	tasklet = &per_cpu_ptr(info->cache->percpu, cpu)->flush_tasklet;
> > +	tasklet = &this_cpu_ptr(info->cache->percpu)->flush_tasklet
> 
> Another case for the use of this_cpu_read

Actually, smp_processor_id() is used if either preemtion is off or
in a thread that is bound to the current cpu. So all code that uses
smp_processor_id() should be able to use __this_cpu_read instead of
this_cpu_read.

In this case, flow_cache_flush_per_cpu() is called via smp_call_function(),
so it is bound on the current cpu.
