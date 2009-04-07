From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12954] New: SAMEIP --nodst functionality gone
 missing
Date: Tue, 7 Apr 2009 14:35:09 -0700
Message-ID: <20090407143509.05ab3b28.akpm@linux-foundation.org>
References: <bug-12954-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, berni@birkenwald.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46351 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752356AbZDGVhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 17:37:18 -0400
In-Reply-To: <bug-12954-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

"massive issues"!

On Fri, 27 Mar 2009 16:48:06 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12954
> 
>            Summary: SAMEIP --nodst functionality gone missing
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.25+
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Netfilter/Iptables
>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>         ReportedBy: berni@birkenwald.de
>         Regression: Yes
> 
> 
> This was already briefly discussed on the netfilter mailinglist, but did not
> spark much response there. However I think this issue is a pretty obvious
> regression over old kernel versions and might hit quite a few people once the
> newer kernels get deployed into large NAT setups.
> 
> Back in the days of 2.6.18 there was the SAME target which allowed, with the
> option '--nodst' to SNAT internal hosts to the same address of a whole SNAT
> range regardless of the destination address.
> 
> In cb76c6a597350534d211ba79d92da1f9771f8226 the SAME target was removed from
> the kernel sources due to being obsolete, since the same functionality was now
> in nf_nat. Shortly after that a discussion Patrick McHardy proposed a patch to
> mimic the behaviour of SAME with --nodst in nf_nat by dropping the destination
> IP from the jhash. The patch was dropped shortly after because it apparently
> showed some uneven distribution.
> 
> The whole thread can be read at
> http://thread.gmane.org/gmane.comp.security.firewalls.netfilter.devel/23275/focus=27670
> .
> 
> This thread went dead, I tried to revive it but did not get an answer. We're
> getting hit by this regression because we are currently NATing some thousand IP
> addresses (student dorms) to an external /28. It works fine with our old
> 2.6.18+SAME setup, but tests with 2.6.25+SNAT showed massive issues with
> connections from the same internal address to different destinations getting
> NATed to different addresses in the pool. Which breaks, for example, ICQ quite
> badly.
> 

