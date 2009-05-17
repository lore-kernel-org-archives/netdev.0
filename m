From: Robert Olsson <robert@robur.slu.se>
Subject: Re: [oops] with FIB_TRIE
Date: Sun, 17 May 2009 15:44:28 +0200
Message-ID: <18960.5308.297655.51837@robur.slu.se>
References: <1242041043.4619.56.camel@ierdnac>
	<18953.37530.49022.415@robur.slu.se>
	<1242302098.3219.13.camel@ierdnac>
	<20090514130035.3cf14d19@nehalam>
	<18956.37696.186135.21348@robur.slu.se>
	<20090516212448.GC6973@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Stephen Hemminger <shemminger@vyatta.com>,
	andrei.popa@i-neo.ro, NetDEV list <netdev@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:58507 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624AbZEQNo2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2009 09:44:28 -0400
In-Reply-To: <20090516212448.GC6973@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Paul E. McKenney writes:

 > >  Need to recap this... at least for myself insert, delete and flush is 
 > >  serialised wrt RTNL I guess this is still OK. We oops in lookup but 
 > >  we should have preempt_disable as we're in a RCU read section. Also we 
 > >  know quagga is constantly running delete...
 > 
 > RCU read-side critical sections are not preempt_disable() if you have
 > built with CONFIG_PREEMPT_RCU.

I've just fixed a setup so we can verify the oops easily in the lab. 

# CONFIG_PREEMPT_RCU is not set
# CONFIG_PREEMPT_RCU_TRACE is not set
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set

Any suggestion where to start? 
I'll guess we'll need to instrument a bit and try to understand what happens. 
softirq can be run by ksoftirqd

CONFIG_PREEMPT=y
ftp://robur.slu.se/pub/Linux/net-development/trie-test/OOPS

Cheers
					--ro

Stephen. rcu_read_lock_bh in trie_loop didn't make any difference
