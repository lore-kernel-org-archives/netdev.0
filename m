From: kuznet@ms2.inr.ac.ru
Subject: Re: route cache DoS testing and softirqs
Date: Thu, 8 Apr 2004 17:29:13 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404081329.RAA16178@yakov.inr.ac.ru>
References: <16498.43191.733850.18276@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dipankar@in.ibm.com, Robert.Olsson@data.slu.se (Robert Olsson),
        andrea@suse.de (Andrea Arcangeli), davem@redhat.com (David S. Miller),
        kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        paulmck@us.ibm.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se (Robert Olsson)
In-Reply-To: <16498.43191.733850.18276@robur.slu.se> from "Robert Olsson" at сав 06, 2004 02:55:19 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> setup. I've done a little experimental patch so *all* softirq's are run via 
> ksoftirqd. 

BTW what's about performance in this extremal situation?

Also, Robert, let's count the numbers again. With this change you should
have latency much less 100msec when priority of ksoftirqd is high.
So, rcu problem must be solved at current flow rates.
This enforces me to suspect we have another source of overflows.
F.e. one silly place could be that you set gc_min_interval via sysctl,
which uses second resolution (yup :-(). With one second you get maximal
ip_rt_max_size/1 second flow rate, it is _not_ a lot.

Alexey
