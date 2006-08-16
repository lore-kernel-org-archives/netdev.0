From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] network namespaces
Date: Wed, 16 Aug 2006 11:35:41 -0600
Message-ID: <m1zme41t3m.fsf@ebiederm.dsl.xmission.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>
	<20060816115313.GC31810@sergelap.austin.ibm.com>
	<20060816151226.GA11687@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Andrey Savochkin <saw@sw.ru>,
	netdev@vger.kernel.org, dlezcano@fr.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	ebiederm@xmission.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	devel@openvz.org, alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:8134 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S1751223AbWHPRhg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 13:37:36 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060816151226.GA11687@ms2.inr.ac.ru> (Alexey Kuznetsov's
	message of "Wed, 16 Aug 2006 19:12:26 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> writes:

> Hello!
>
>> (application) containers.  Performance aside, are there any reasons why
>> this approach would be problematic for c/r?
>
> This approach is just perfect for c/r.

Yes.  For c/r you need to take your state with you.

> Probably, this is the only approach when migration can be done
> in a clean and self-consistent way.

Basically there are currently 3 approaches that have been proposed.

The trivial bsdjail style as implemented by Serge and in a slightly
more sophisticated version in vserver.  This approach as it does not
touch the packets has little to no packet level overhead.  Basically
this is what I have called the Level 3 approach.

The more in depth approach where we modify the packet processing based
upon which network interface the packet comes in on, and it looks like
each namespace has it's own instance of the network stack. Roughly
what was proposed earlier in this thread the Level 2 approach.  This
potentially has per packet overhead so we need to watch the implementation
very carefully.

Some weird hybrid as proposed by Daniel, that I was never clear on the
semantics.

>From the previous conversations my impression was that as long as
we could get a Layer 2 approach that did not slow down the networking
stack and was clean, everyone would be happy.

I'm buried in the process id namespace at the moment, and except
to be so for the rest of the month, so I'm not going to be
very helpful except for a few stray comments.

Eric
