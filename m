From: Robert Olsson <robert@robur.slu.se>
Subject: Re: [oops] with FIB_TRIE
Date: Thu, 14 May 2009 23:55:12 +0200
Message-ID: <18956.37696.186135.21348@robur.slu.se>
References: <1242041043.4619.56.camel@ierdnac>
	<18953.37530.49022.415@robur.slu.se>
	<1242302098.3219.13.camel@ierdnac>
	<20090514130035.3cf14d19@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrei.popa@i-neo.ro, Robert Olsson <Robert.Olsson@data.slu.se>,
	NetDEV list <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:34050 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754905AbZENVzM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2009 17:55:12 -0400
In-Reply-To: <20090514130035.3cf14d19@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen Hemminger writes:

 > > I recompiled the kernel with FIB_TRIE and no preemption and it doesn't
 > > oops anymore.

 Thanks, for testing Andrei. I've had routing tables continusly going up
 and down for 24 hours (with no preemption) without any problem.

 > Maybe the rcu_read_lock needs to be rcu_read_lock_bh?

 Maybe,
 Need to recap this... at least for myself insert, delete and flush is 
 serialised wrt RTNL I guess this is still OK. We oops in lookup but 
 we should have preempt_disable as we're in a RCU read section. Also we 
 know quagga is constantly running delete...

 Cheers
					--ro
