From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 12:49:31 +0100
Message-ID: <87637zdy9g.fsf@basil.nowhere.org>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu>
	<4B2F9582.5000002@gmail.com> <4B2F978D.7010602@redhat.com>
	<4B2F9C85.7070202@gmail.com> <4B2FA42F.3070408@codemonkey.ws>
	<4B2FA655.6030205@gmail.com> <4B2FAE7B.9030005@codemonkey.ws>
	<4B2FB3F1.5080808@gmail.com> <4B300EF8.8010602@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56993 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbZLVLtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 06:49:36 -0500
In-Reply-To: <4B300EF8.8010602@codemonkey.ws> (Anthony Liguori's message of "Mon, 21 Dec 2009 18:12:40 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anthony Liguori <anthony@codemonkey.ws> writes:
>
> On a modern Nehalem, I would be surprised if an MMIO exit handled in
> the kernel was muck more than 2us.  The hardware is getting very, very
> fast.  The trends here are very important to consider when we're
> looking at architectures that we potentially are going to support for
> a long time.

When you talk about trends the trend for IO is also to get faster.

An exit will be always more expensive than passing something from
another CPU in shared memory. An exit is much more work,
with lots of saved context and fundamentally synchronous, 
even with all the tricks hardware can do.  And then there's the
in kernel handler too.

Shared memory passing from another CPU is a much cheaper 
operation and more likely to scale with IO rate improvements.

The basic problem in this discussion seems to be the usual
disconnect between working code (I understand Gregory has working
code that demonstrates the performance advances he's claiming)
versus unwritten optimizations.

Unwritten code tends to always sound nicer, but it remains to be seen
if it can deliver what it promises.

>From a abstract stand point having efficient paravirtual IO interfaces
seem attractive.

I also personally don't see a big problem in having another set of
virtual drivers -- Linux already has plenty (vmware, xen, virtio, power,
s390-vm, ...) and it's not that they would be a particular maintenance
burden impacting the kernel core.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
