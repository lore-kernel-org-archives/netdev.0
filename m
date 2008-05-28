From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Wed, 28 May 2008 11:27:14 +0200
Message-ID: <1211966834.12349.62.camel@twins>
References: <20080526115628.GA31316@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753906AbYE1J2X@vger.kernel.org>
In-Reply-To: <20080526115628.GA31316@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-05-26 at 13:56 +0200, Ingo Molnar wrote:
> in an overnight -tip testruns that is based on recent -git i got two 
> stuck TCP connections:
> 
> Active Internet connections (w/o servers)
> Proto Recv-Q Send-Q Local Address               Foreign Address
> State      
> tcp        0 174592 10.0.1.14:58015             10.0.1.14:3632
> ESTABLISHED 
> tcp    72134      0 10.0.1.14:3632              10.0.1.14:58015
> ESTABLISHED 
> 
> on a previously reliable machine. That connection has been stuck for 9 
> hours so it does not time out, etc. - and the distcc run that goes over 
> that connection is stuck as well.
> 
> kernel config is attached.
> 
> in terms of debugging there's not much i can do i'm afraid. It's not 
> possible to get a tcpdump of this incident, given the extreme amount of 
> load these testboxes handle. This problem started sometime around rc3 
> and it occured on two boxes (on a laptop and on a desktop), both are SMP 
> Core2Duo based systems. I never saw this problem before on thousands of 
> similar bootups, so i'm 99.9% sure the bug is either new or became 
> easier to trigger.
> 
> It's not possible to bisect it as it needs up to 12 hours of heavy 
> workload to trigger. The incident happened about 5 times since the first 
> incident a couple of days ago - 4 times on one box and once on another 
> box. The first failing head i became aware of was 78b58e549a3098. (-tip 
> has other changes beyond -git but changes nothing in networking.)
> 
> One clue (which might or might not matter) is that distcc is one of the 
> very few applications that makes use of sendfile().

Just a quick note to say, me too!!

same scenario: distcc on localhost.
