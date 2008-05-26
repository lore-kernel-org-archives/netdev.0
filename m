From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Mon, 26 May 2008 16:28:18 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805261550340.16829@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45683 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbYEZN2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 09:28:25 -0400
In-Reply-To: <20080526115628.GA31316@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 May 2008, Ingo Molnar wrote:

> in an overnight -tip testruns that is based on recent -git i got two 
> stuck TCP connections:
> 
> Active Internet connections (w/o servers)
> Proto Recv-Q Send-Q Local Address               Foreign Address             State      
> tcp        0 174592 10.0.1.14:58015             10.0.1.14:3632              ESTABLISHED 
> tcp    72134      0 10.0.1.14:3632              10.0.1.14:58015             ESTABLISHED 
> 
> on a previously reliable machine. That connection has been stuck for 9 
> hours so it does not time out, etc. - and the distcc run that goes over 
> that connection is stuck as well.
> 
> kernel config is attached.
> 
> in terms of debugging there's not much i can do i'm afraid. It's not 
> possible to get a tcpdump of this incident, given the extreme amount of 
> load these testboxes handle.

...but you can still tcpdump that particular flow once the situation is 
discovered to see if TCP still tries to do something, no? One needs to 
tcpdump couple of minutes at minimum. Also please get /proc/net/tcp for 
that flow around the same time.

> This problem started sometime around rc3 
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

Can you please try with /proc/sys/net/ipv4/tcp_frto set to zero though 
recv-q symptom seems weird would it be related to that (but there were 
some recent fixes to FRTO and retrans_stamp change could have some 
significance here)?

Other than that, nothing since -rc1 seems suspicious to me (though
I hardly understand every part of networking).


-- 
 i.
