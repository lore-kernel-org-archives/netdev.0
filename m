From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Wed, 21 Oct 2009 12:51:39 -0400
Message-ID: <20091021165139.GL877@kvack.org>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:51504 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753926AbZJUQvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2009 12:51:35 -0400
Content-Disposition: inline
In-Reply-To: <4ADF2B57.4030708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2009 at 05:40:07PM +0200, Eric Dumazet wrote:
> Ben patch only address interface deletion, and one part of the problem,
> maybe the more visible one for the current kernel.

The first part I've been tackling has been the overhead in procfs, sysctl 
and sysfs.  I've got patches for some of the issues, hacks for others, and 
should have something to post in a few days.  Getting rid of those overheads 
is enough to get to decent interface creation times for the first 20 or 30k 
interfaces.

On the interface deletion side of things, within the network code, fib_hash 
has a few linear scans that really start hurting.  trie is a bit better, 
but I haven't started digging too deeply into its flush/remove overhead yet, 
aside from noticing that trie has a linear scan if 
CONFIG_IP_ROUTE_MULTIPATH is set since it sets the hash size to 1.  
fn_trie_flush() is currently the worst offender during deletion.

		-ben
