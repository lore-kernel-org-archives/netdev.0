From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via
 /proc
Date: Mon, 8 Nov 2010 00:56:10 +0100
Message-ID: <20101107235610.GE17592@basil.fritz.box>
References: <201011072248.oA7MmjKg025857@cmf.nrl.navy.mil>
 <1289172456.3090.184.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas3@users.sourceforge.net, Andi Kleen <andi@firstfloor.org>,
	Ted Ts'o <tytso@mit.edu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"pekkas@netcore.fi" <pekkas@netcore.fi>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"remi.denis-courmont@nokia.com" <remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"security@kernel.org" <security@kernel.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:48165 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218Ab0KGX4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 18:56:13 -0500
Content-Disposition: inline
In-Reply-To: <1289172456.3090.184.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The criticism raised so far is that cutting out the pointers entirely
> results in the omission of potentially useful debugging information.  I
> see two viable options to address this: either print out or omit
> addresses based on privileges (CAP_NET_ADMIN, for example), or have it
> controllable via sysctl.  I'm leaning towards the sysctl
> option...thoughts?

I would just remove the pointers from /proc and supply 
gdb macros that extract the equivalent information from /proc/kcore.
This is a bit racy, but for debugging it should be no
problem to run them multiple times as needed.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
