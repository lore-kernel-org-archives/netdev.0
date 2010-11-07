From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via
 /proc
Date: Mon, 8 Nov 2010 00:29:34 +0100
Message-ID: <20101107232934.GD17592@basil.fritz.box>
References: <87sjzcssx5.fsf@basil.nowhere.org>
 <201011072248.oA7MmjKg025857@cmf.nrl.navy.mil>
 <AANLkTikDeVXcYRXqcq-qD_mf19awnKPTYGZbZguxJLDm@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas3@users.sourceforge.net, Andi Kleen <andi@firstfloor.org>,
	Ted Ts'o <tytso@mit.edu>,
	Dan Rosenberg <drosenberg@vsecurity.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"pekkas@netcore.fi" <pekkas@netcore.fi>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"remi.denis-courmont@nokia.com" <remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"security@kernel.org" <security@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:48997 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753704Ab0KGX3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 18:29:36 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTikDeVXcYRXqcq-qD_mf19awnKPTYGZbZguxJLDm@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So the only question is whether kernel pointers are an information
> leak worth worrying about. Personally, I think it's just damn stupid
> to expose a kernel pointer unless you _have_ to. There is absolutely

Agreed.

> no reason to expose the address of a socket in /proc, perhaps unless
> you're in some super-duper-debugging mode that no sane person would
> ever use outside of specialized network debugging (and I bet that in
> that case you still shouldn't expose it in a _normal_ proc file, but
> in debugfs or something).

In most cases you can get them by running gdb or crash on /proc/kcore 
anyways.

Still overall I suspect there may be a case that making
dmesg root only is a good idea.  At least optionally for the non 
kernel hackers out there.

The early memory map information can be likely used to guess a lot of 
locations and perhaps really make that heap overflow easier to write.
And perhaps some more mapping randomization inside the kernel.

I'm not sure the case is very strong though.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
