From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Fix 2.6.34-rc1 regression in  disable_ipv6 support
Date: Thu, 09 Dec 2010 11:31:36 -0800
Message-ID: <m1y67y3fqf.fsf@fess.ebiederm.org>
References: <m17hfnlpe1.fsf@fess.ebiederm.org> <4CFD0AF0.9090809@hp.com>
	<m14oaoeywf.fsf@fess.ebiederm.org> <4D000B6D.1060708@hp.com>
	<m1tyineu3p.fsf@fess.ebiederm.org> <20101208154932.5bc4b254@nehalam>
	<m11v5rekg3.fsf@fess.ebiederm.org> <m1ipz3d46m.fsf@fess.ebiederm.org>
	<m1mxofa8dg.fsf_-_@fess.ebiederm.org> <4D00F58A.2050307@hp.com>
	<m139q6ahld.fsf@fess.ebiederm.org> <20101209111611.1d2e6e2b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Mahesh Kelkar <maheshkelkar@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, stable@kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55932 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755395Ab0LITbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 14:31:41 -0500
In-Reply-To: <20101209111611.1d2e6e2b@nehalam> (Stephen Hemminger's message of
	"Thu, 9 Dec 2010 11:16:11 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> On Thu, 09 Dec 2010 11:09:34 -0800
> ebiederm@xmission.com (Eric W. Biederman) wrote:
> So let's please keep this a line that we can easily remove.  It isn't
> like interfaces coming up and down are a fast path where every cycle
> counts.  We just need to be reasonably efficient.

> No but since removing address propagates up to user space daemons
> like Quagga please analyze and fix the problem, don't just look
> for band aid.

You fix the problem.  You introduced the regression, and you didn't test
that keeping addresses actually worked.  This is not the first patch
that has been applied to fix regressions in this area.

I introduced a targeted revert of your broken change that only preserves
the one address people are least likely to change.

I know people are not downing the ipv6 loopback interface in practice
and bringing it back up because in practice on running systems because
that breaks ipv6 networking.  So quagga should not see this issue
in practice.

Right now misplaced perfectionism is being a huge enemy of creating
a kernel that actually works.

Eric

