From: N N Ashok <nalkunda@egr.msu.edu>
Subject: Re: Kernel locking up in module
Date: Thu, 17 Jul 2003 00:18:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307170018.11043.nalkunda@egr.msu.edu>
References: <OFF7117350.353FDF6E-ON88256D64.00016172@us.ibm.com> <200307142031.15122.nalkunda@egr.msu.edu> <200307152128.34341.nalkunda@egr.msu.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kumarkr@us.ibm.com>
In-Reply-To: <200307152128.34341.nalkunda@egr.msu.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

<snipped...>
>
>         From what I read in "Understanding the Linux Kernel", the timer
> routine that I setup is executed from the bottom half. Also in the book it
> says that data structures accessed in deferrable functions (which a bottom
> handler is I think), there is no need of any kind of locking/protection
> required for uniprocessor machines. Also it says that if we try to acquire
> a spin_lock on a uniprocessor in the kernel, then the kernel control path
> that does have the lock will not get a chance to release the lock and hence
> we will have a deadlock.
>        In this context, I am unable to understand whether I should use
> locking and if so which kind. Do I need to disable the IRQs (_irq) when I
> take the lock? Or do I disable the bottom halves (_bh) ? Please help me in
> understanding and resolving the problem as it is required for my thesis.
>
> Thanks and Regards,
> Ashok

Hi,
   I understand that on uniprocessor machines, spin locks are just empty. Is 
that true? The code that I was looking at from include/linux/spinlock.h was 
(although there are 2-3 other definitions for these but they also essentially 
are not doing much):

 #define rwlock_init(lock)	do { } while(0)
#define read_lock(lock)		(void)(lock) /* Not "unused variable". */
#define read_unlock(lock)	do { } while(0)
#define write_lock(lock)	(void)(lock) /* Not "unused variable". */
#define write_unlock(lock)	do { } while(0)

Can somebody confirm this? If so then how do we protect data structures in 
kernel control paths?

Thanks,
Ashok
