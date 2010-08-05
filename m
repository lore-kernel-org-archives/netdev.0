From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16517] New: rp_filter fails to filter with
 CONFIG_IP_ROUTE_MULTIPATH and more than one 0/0 nexthop dev
Date: Thu, 5 Aug 2010 13:46:53 -0700
Message-ID: <20100805134653.9e8985cc.akpm@linux-foundation.org>
References: <bug-16517-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	for.poige+bugzilla.kernel.org@gmail.com
To: netfilter@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40776 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932426Ab0HEU53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 16:57:29 -0400
In-Reply-To: <bug-16517-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 5 Aug 2010 01:48:01 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16517
> 
>            Summary: rp_filter fails to filter with
>                     CONFIG_IP_ROUTE_MULTIPATH and more than one 0/0
>                     nexthop dev
>            Product: Networking
>            Version: 2.5
>     Kernel Version: at least 2.6.18 and newer
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: for.poige+bugzilla.kernel.org@gmail.com
>         Regression: No
> 
> 
> I think the problem is net/ipv4/fib_frontend.c fib_validate_source()
> 
> ...
> #ifdef CONFIG_IP_ROUTE_MULTIPATH
>     if (FIB_RES_DEV(res) == dev || res.fi->fib_nhs > 1)
> #else
>     if (FIB_RES_DEV(res) == dev)
> #endif
> ...
> 
> I'm not sure, but this code is quite trivial and self-speaking. In case we have
> several default routes, we'd better iterate over each of them and compare
> resulting devices with the input one. So, fix is also trivial, specially for
> network kernel developers. ;-)
> 
> I've set priority "High" cause it doesn't affects usual Linux users directly,
> but indirectly it can affect any host on Internet, so the problem is
> significant, of course.
> 
> P. S. Kernel docs say: {
> rp_filter - INTEGER
>         0 - No source validation.
>         1 - Strict mode as defined in RFC3704 Strict Reverse Path
>             Each incoming packet is tested against the FIB and if the interface
>             is not the best reverse path the packet check will fail.
>             By default failed packets are discarded.
>         2 - Loose mode as defined in RFC3704 Loose Reverse Path
>             Each incoming packet's source address is also tested against the
> FIB
>             and if the source address is not reachable via any interface
>             the packet check will fail.
> 
>         Current recommended practice in RFC3704 is to enable strict mode
>         to prevent IP spoofing from DDos attacks. If using asymmetric routing
>         or other complicated routing, then loose mode is recommended.
> 
>         conf/all/rp_filter must also be set to non-zero to do source validation
>         on the interface
> 
>         Default value is 0. Note that some distributions enable it
>         in startup scripts.
> }, but is in reality level "2" of rp_filtering implemented?
> 
> P. P. S. netfilter would be the best place to have Reverse Path checks. But
> that's another story.
> 

