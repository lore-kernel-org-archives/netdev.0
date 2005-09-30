From: Suzanne Wood <suzannew@cs.pdx.edu>
Subject: Re: [RFC][PATCH] identify in_dev_get rcu read-side critical sections
Date: Thu, 29 Sep 2005 18:06:50 -0700 (PDT)
Message-ID: <200509300106.j8U16obP021064@rastaban.cs.pdx.edu>
Cc: Robert.Olsson@data.slu.se, davem@davemloft.net,
        herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, walpole@cs.pdx.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: paulmck@us.ibm.com, suzannew@cs.pdx.edu
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In reviewing the 44 kernel uses of __in_dev_get and seeing many 
cases in 13 of 20 C code files of insertions of rcu_read_lock with 
and without the rcu_dereference that is indicated, so it does appear 
often to be programmer intent.  

Of the programs using __in_dev_get that don't include rcu, devinet.c 
and igmp.c use an rtnl lock.  Five other programs that use __in_dev_get 
without rcu have rtnl locking in the program source code, but I need 
to actually look further into the call tree to say more.

Are there three cases then?  RCU protection with refcnt, RCU without refcnt,
and the bare cast of the dereference? 

Thank you very much for getting it back on track.

  > From paulmck@us.ibm.com  Thu Sep 29 17:23:18 2005

  > Is there any case where __in_dev_get() might be called without
  > needing to be wrapped with rcu_dereference()?  If so, then I
  > agree (FWIW, given my meagre knowledge of Linux networking).

  > If all __in_dev_get() invocations need to be wrapped in
  > rcu_dereference(), then it seems to me that there would be
  > motivation to bury rcu_dereference() in __in_dev_get().

  > > > Some callers of __in_dev_get() don't need rcu_dereference at all
  > > > because they're protected by the rtnl.
  > > 
  > > > BTW, could you please move the rcu_dereference in in_dev_get()
  > > > into the if clause? The barrier is not needed when ip_ptr is
  > > > NULL.
  > > 
  > > The trouble with that may be that there are three events, the
  > > dereference, the assignment, and the conditional test.  The
  > > rcu_dereference() is meant to assure deferred destruction
  > > throughout.

  > One only needs an rcu_dereference() once on the data-flow path from
  > fetching the RCU-protected pointer to dereferencing that pointer.
  > If the pointer is NULL, there is no way you can dereference it,
  > so, technically, Herbert is quite correct.

  > However, rcu_dereference() only generates a memory barrier on DEC
  > Alpha, so there is normally no penalty for using it in the NULL-pointer
  > case.  So, when using rcu_dereference() unconditionally simplifies
  > the code, it may make sense to "just do it".

  > 							Thanx, Paul
