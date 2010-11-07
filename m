From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via
 /proc
Date: Sun, 07 Nov 2010 18:27:36 -0500
Message-ID: <1289172456.3090.184.camel@Dan>
References: <201011072248.oA7MmjKg025857@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, Ted Ts'o <tytso@mit.edu>,
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
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:62453 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab0KGX1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 18:27:38 -0500
In-Reply-To: <201011072248.oA7MmjKg025857@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on the feedback so far, I think a few things need to be worked
out.  Firstly, I'm going to separate out printk leaks as an issue to be
worked on at a later time - it seems there is some interest in
evaluating whether dmesg should be restricted, but that is out of scope
of my plans for this patch series.

That leaves the /proc leakage.  I don't think XOR-ing is a viable
option, since it would be relatively easy to infer the constant value.
The criticism raised so far is that cutting out the pointers entirely
results in the omission of potentially useful debugging information.  I
see two viable options to address this: either print out or omit
addresses based on privileges (CAP_NET_ADMIN, for example), or have it
controllable via sysctl.  I'm leaning towards the sysctl
option...thoughts?

-Dan

