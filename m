From: David Miller <davem@davemloft.net>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Tue, 06 Feb 2007 11:43:25 -0800 (PST)
Message-ID: <20070206.114325.98862918.davem@davemloft.net>
References: <20070205.184408.34759062.davem@davemloft.net>
	<20070205185324.16b54b64.akpm@linux-foundation.org>
	<20070206123401.GA8052@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, kaber@trash.net,
	dipankar@in.ibm.com, paulmck@us.ibm.com
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39712
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752285AbXBFTn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 14:43:26 -0500
In-Reply-To: <20070206123401.GA8052@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 6 Feb 2007 13:34:01 +0100

> 
> * Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Mon, 05 Feb 2007 18:44:08 -0800 (PST) David Miller 
> > <davem@davemloft.net> wrote:
> > 
> > > I bet this rcu_read_lock()-implies-preempt_disable() assumption has 
> > > spread into other areas of the tree as well.
> > 
> > Me too.  Although one expects that other holes will cause might_sleep 
> > or lockdep warnings pretty easily.
> > 
> > Still, life is hard enough as it is.  I think I'll shelve rcu-preempt 
> > pending resolution of this.
> 
> that was pretty much the only place in the whole kernel that got hit by 
> some rcu-preempt side-effect - and even this appears to show that it's a 
> real bug that was in hiding.

No, rather, it's the only location that triggered an automated
debugging check.  The very first set of code paths we checked, in
response to the bug trigger, showed beyond a shadow of a doubt that
this assumption is pervasive and in many locations that none of the
automated debugging checks live.

The tree should be fully audited before such a huge semantic change
gets added into the tree.

