From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: route cache DoS testing and softirqs
Date: Wed, 7 Apr 2004 01:22:49 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040406195249.GA4581@in.ibm.com>
References: <20040330133000.098761e2.davem@redhat.com> <20040330213742.GL3808@dualathlon.random> <20040331171023.GA4543@in.ibm.com> <16491.4593.718724.277551@robur.slu.se> <20040331203750.GB4543@in.ibm.com> <20040331212817.GQ2143@dualathlon.random> <20040331214342.GD4543@in.ibm.com> <16497.37720.607342.193544@robur.slu.se> <20040405212220.GH4003@in.ibm.com> <16498.43191.733850.18276@robur.slu.se>
Reply-To: dipankar@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrea Arcangeli <andrea@suse.de>, "David S. Miller" <davem@redhat.com>,
        kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        paulmck@us.ibm.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16498.43191.733850.18276@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 06, 2004 at 02:55:19PM +0200, Robert Olsson wrote:
Content-Description: message body text
> Dipankar Sarma writes:
>  > Looks better atleast. Can you apply the following patch (rs-throttle-rcu)
>  > on top of rcu-softirq.patch in your tree and see if helps a little bit more ?
>  > Please make sure to set the kernel paramenters rcupdate.maxbatch to 4
>  > and rcupdate.plugticks to 0. You can make sure of those parameters
>  > by looking at dmesg (rcu prints them out during boot). I just merged
>  > it, but have not tested this patch yet.
> 
> OK!
> 
> Well not tested yet but I don't think we will get rid overflow totally in my 
> setup. I've done a little experimental patch so *all* softirq's are run via 
> ksoftirqd. 

Robert, you should try out rs-throttle-rcu.patch. The idea is that
we don't run too many callbacks in a single rcu. In my setup,
at 100kpps, I see as many as 30000 rcu callbacks in a single
tasklet handler. That is likely hurting even the softirq-only
RCU grace periods. Setting rcupdate.maxbatch=4 will do only 4 per
tasklet thus providing more quiescent points to the system.

Thanks
Dipankar
