From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH bridge 4/5] bridge: Add private ioctls to configure
 vlans on bridge ports
Date: Fri, 24 Aug 2012 11:11:13 -0700
Message-ID: <20120824111113.08b8c1a6@nehalam.linuxnetplumber.net>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
	<1345750195-31598-5-git-send-email-vyasevic@redhat.com>
	<20120824175616.GL2472@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58210 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753986Ab2HXSLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2012 14:11:32 -0400
In-Reply-To: <20120824175616.GL2472@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Aug 2012 10:56:16 -0700
"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:

> > +			return -EPERM;
> > +
> > +		rcu_read_lock();
> > +		if ((p = br_get_port(br, args[1])) == NULL) {
> > +			rcu_read_unlock();
> > +			return -EINVAL;
> > +		}
> > +		rcu_read_unlock();  
> 
> Why is it safe to pass "p" out of the RCU read-side critical section?
> I don't see that br_get_port() does anything to make this safe, at least
> not in v3.5.

It would be accidentally protected by rtnl?
