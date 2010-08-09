From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Mon, 09 Aug 2010 14:17:13 -0700
Message-ID: <m1mxsvv63q.fsf@fess.ebiederm.org>
References: <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org>
	<200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com>
	<20091021165139.GL877@kvack.org> <m1d445yf2x.fsf@fess.ebiederm.org>
	<20091029233848.GV3141@kvack.org> <4C603999.1030801@candelatech.com>
	<20100809173429.GR30010@kvack.org> <m1tyn3v9pp.fsf@fess.ebiederm.org>
	<20100809210311.GW30010@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48569 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755196Ab0HIVRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 17:17:19 -0400
In-Reply-To: <20100809210311.GW30010@kvack.org> (Benjamin LaHaise's message of
	"Mon, 9 Aug 2010 17:03:11 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise <bcrl@lhnet.ca> writes:

> On Mon, Aug 09, 2010 at 12:59:14PM -0700, Eric W. Biederman wrote:
>> The network device deletion batching code has gone in, which is
>> a big help, as have some dev_put deletions, so we hit that 250ms
>> delay less often.  
>
> I'll see how much that helps.  Odds are I'm going to have to move the 
> device deletion into a separate thread.  That should give me a natural 
> boundary to queue up deletions at, which should fix the tunnel-flap and 
> partial tunnel-flap cases I'm worried about.  At some point I have to 
> figure out how to get my API needs met by the in-kernel L2TP code, but 
> that's a worry for another day.

In case it is useful, if you delete a network namespace in general
all of the network device deletions can be batched.  

Eric
