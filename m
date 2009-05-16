From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [oops] with FIB_TRIE
Date: Sat, 16 May 2009 14:24:48 -0700
Message-ID: <20090516212448.GC6973@linux.vnet.ibm.com>
References: <1242041043.4619.56.camel@ierdnac> <18953.37530.49022.415@robur.slu.se> <1242302098.3219.13.camel@ierdnac> <20090514130035.3cf14d19@nehalam> <18956.37696.186135.21348@robur.slu.se>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, andrei.popa@i-neo.ro,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	NetDEV list <netdev@vger.kernel.org>
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:46065 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754388AbZEPVYt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 May 2009 17:24:49 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4GLKopB017258
	for <netdev@vger.kernel.org>; Sat, 16 May 2009 17:20:50 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4GLOlB7254648
	for <netdev@vger.kernel.org>; Sat, 16 May 2009 17:24:50 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4GLOkcr022774
	for <netdev@vger.kernel.org>; Sat, 16 May 2009 17:24:47 -0400
Content-Disposition: inline
In-Reply-To: <18956.37696.186135.21348@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2009 at 11:55:12PM +0200, Robert Olsson wrote:
> 
> Stephen Hemminger writes:
> 
>  > > I recompiled the kernel with FIB_TRIE and no preemption and it doesn't
>  > > oops anymore.
> 
>  Thanks, for testing Andrei. I've had routing tables continusly going up
>  and down for 24 hours (with no preemption) without any problem.
> 
>  > Maybe the rcu_read_lock needs to be rcu_read_lock_bh?
> 
>  Maybe,
>  Need to recap this... at least for myself insert, delete and flush is 
>  serialised wrt RTNL I guess this is still OK. We oops in lookup but 
>  we should have preempt_disable as we're in a RCU read section. Also we 
>  know quagga is constantly running delete...

RCU read-side critical sections are not preempt_disable() if you have
built with CONFIG_PREEMPT_RCU.

							Thanx, Paul
