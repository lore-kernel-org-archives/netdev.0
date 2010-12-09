From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Fix 2.6.34-rc1 regression in  disable_ipv6 support
Date: Thu, 09 Dec 2010 11:09:34 -0800
Message-ID: <m139q6ahld.fsf@fess.ebiederm.org>
References: <m17hfnlpe1.fsf@fess.ebiederm.org> <4CFD0AF0.9090809@hp.com>
	<m14oaoeywf.fsf@fess.ebiederm.org> <4D000B6D.1060708@hp.com>
	<m1tyineu3p.fsf@fess.ebiederm.org> <20101208154932.5bc4b254@nehalam>
	<m11v5rekg3.fsf@fess.ebiederm.org> <m1ipz3d46m.fsf@fess.ebiederm.org>
	<m1mxofa8dg.fsf_-_@fess.ebiederm.org> <4D00F58A.2050307@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Mahesh Kelkar <maheshkelkar@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Stephen Hemminger <shemminger@vyatta.com>, stable@kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41932 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756580Ab0LITJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 14:09:44 -0500
In-Reply-To: <4D00F58A.2050307@hp.com> (Brian Haley's message of "Thu, 09 Dec
	2010 10:28:10 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> writes:

> On 12/08/2010 11:16 PM, Eric W. Biederman wrote:
>> Finding the real bug is beyond me right now, but fixing the regression
>> in disable_ipv6 is simple.  We can just delete ::1 when we bring down
>> the loopback interface, and it will be restored automatically when we
>> bring the loopback interface back up.
>
> Hi Eric,
>
> This would work as well, same check, different way.

But that looks like less of an obvious magic exception.  The only
address it is safe to ignore on is ::1, because we always restore it
when we bring the loopback interface up.

Long term we really do want to keep the loopback address.  But
that actually requires finding and fixing what is broken in
ipv6.

So let's please keep this a line that we can easily remove.  It isn't
like interfaces coming up and down are a fast path where every cycle
counts.  We just need to be reasonably efficient.

Eric
