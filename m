From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Tue, 6 Feb 2007 22:02:51 +0100
Message-ID: <20070206210250.GB25430@elte.hu>
References: <20070205.184408.34759062.davem@davemloft.net> <20070205185324.16b54b64.akpm@linux-foundation.org> <20070206123401.GA8052@elte.hu> <20070206.114325.98862918.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, kaber@trash.net,
	dipankar@in.ibm.com, paulmck@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:55855 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965471AbXBFVDI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 16:03:08 -0500
Content-Disposition: inline
In-Reply-To: <20070206.114325.98862918.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> > that was pretty much the only place in the whole kernel that got hit 
> > by some rcu-preempt side-effect - and even this appears to show that 
> > it's a real bug that was in hiding.
> 
> No, rather, it's the only location that triggered an automated 
> debugging check.  The very first set of code paths we checked, in 
> response to the bug trigger, showed beyond a shadow of a doubt that 
> this assumption is pervasive and in many locations that none of the 
> automated debugging checks live.
> 
> The tree should be fully audited before such a huge semantic change 
> gets added into the tree.

i'd like to add more automated checks to the tree. 'naked' 
smp_processor_id() use is one telltale sign of such a problem - what 
other instances could you suggest me to check? The thing is, in 99% of 
the cases the smp_processor_id() check caught such assumptions in other 
code because 'preempt off' is inextricably connected to /some/ use of 
smp_processor_id() - be it get_cpu_var() or any other derivative 
interface. So i'm wondering what other assumptions there are (or can be) 
about rcu_read_lock() also being a preempt-off point. Thanks!

(btw., i always argued that neither preempt_disable() nor 
rcu_read_lock() is an ideal interface for locking because both hide 
critical assumptions and dependencies - and they both are able to create 
little versions of the 'big BKL mess' that we had to fight a few years 
ago. (and that we still have to fight today, in certain areas of code.))

	Ingo
