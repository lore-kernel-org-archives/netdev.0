From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Kernel locking up in module
Date: Mon, 14 Jul 2003 15:49:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030714154946.27369852.shemminger@osdl.org>
References: <200307141746.30761.nalkunda@egr.msu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: N N Ashok <nalkunda@egr.msu.edu>
In-Reply-To: <200307141746.30761.nalkunda@egr.msu.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Jul 2003 17:46:30 -0400
N N Ashok <nalkunda@egr.msu.edu> wrote:

> Hi All,
>     I am creating a module to measure the outgoing bandwidth usage on the 
> interfaces. It uses the get_stats() of the device to get the current stats 
> and then computes the bandwidth usage. The algorithm for the usage 
> calculation are borrowed from iproute2 package (tc/tc_estimator.c).
>   The problem is that the kernel keeps locking up. I am using rwlock_t locks 
> to lock the data. In the code, I traverse the list of bwuage structures and 
> as a debug message am printing whether the traversal ended in the variable 
> becoming null (which it should if everything went right), but the variable is 
> non-null every other time I insert the module. 
> 	printk(KERN_INFO "bwestimator: dev: %s. bwusage: %s.\n", dev ? "non-null" : 
> "null", bwusage ? "non-null" : "null");
> 
>   I think this has got to do with some locking issues. As this is my first go 
> at the kernel locking, I might have used the wrong kind of locks. I have 
> attached the module source, header and the log messages as I inserted the 
> module a couple of times. I request you all to please help me as I am totally 
> lost here.
> 
> Thanks,
> Ashok


You are not locking out the bottom half receive thread so it will deadlock
when it runs while your code holds the top half lock.
