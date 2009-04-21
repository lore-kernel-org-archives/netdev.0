From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 13:14:56 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904211308510.2199@localhost.localdomain>
References: <20090417012812.GA25534@linux.vnet.ibm.com> <20090418094001.GA2369@ioremap.net> <20090418141455.GA7082@linux.vnet.ibm.com> <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com>
 <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain> <20090421183429.GL6642@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Paul Mackerras <paulus@samba.org>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41470 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751169AbZDUUZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 16:25:43 -0400
In-Reply-To: <20090421183429.GL6642@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 21 Apr 2009, Paul E. McKenney wrote:
> 
> I believe that at least some of this is naming...

Maybe.

I do agree that the way netfilter would use the lock is somewhat different 
from a normal 'reader-writer' lock, since this special case of readers is 
about a per-cpu thing.

> So, would it help if the function names names in this patch said something
> about "local" and "global" rather than "read" and "write"?

Oh, I would have no problem at all with 'local' and 'global', in fact it 
would explain _why_ that read-write lock works.

The problem with naming I have is with the 'recursive' part. There is no 
ambiguity what-so-ever about what a "recursive lock" is (at least of the 
traditional kind), and the lock described here is not it.

So don't get me wrong - I could certainly live with a special lock in the 
networking. BUT:

 - it had damn well be documented as to what it does, and why it works

 - and it had better actually _work_, and not be buggy.

I suspect that using our regular reader-writer locks works well enough, 
and yes, it's probably worth making it really clear that the reader 
variety can only ever be used in the "local" form. That kind of is implied 
by the whole function, though.

And if somebody wants to open-code it as a per-cpu spinlock and a per-cpu 
'local counter', I can live with that too, but at that point I want people 
to just be a lot more careful, and also document it a lot more. 

		Linus
