From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10443] New: VLAN: link level multicasts
 addresses disappears...
Date: Fri, 11 Apr 2008 21:41:34 -0700
Message-ID: <20080411214134.dd7a9ffc.akpm@linux-foundation.org>
References: <bug-10443-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, dmitry@butskoy.name,
	Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54176 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751039AbYDLEl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 00:41:59 -0400
In-Reply-To: <bug-10443-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 11 Apr 2008 09:18:07 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10443
> 
>            Summary: VLAN: link level multicasts addresses disappears...
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.23.15
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: dmitry@butskoy.name
> 
> 
> Each IP interface in the UP state "have" appropriate multicast addresses, which
> can be shown by "ip maddr show" output.
> 
> For example, for an ordinary one-card computer, "ip maddr show" shows something
> like:
> 
> 1:      lo
>         inet  224.0.0.1
> 2:      eth0
>         link  01:00:5e:00:00:01
>         inet  224.0.0.1
> 
> or something more if IPv6 is enabled.
> 
> I've discovered an issue with the link layer multicasts (aka 01:00:5e:00:00:01
> in the example above) and VLAN devices.
> 
> 
> When I do some non-trivial vlan manipulations (more than one vlan device, "set
> up/set down" several times, etc.), "ip maddr show" shows either the wrong
> "users %d" count for "link" addresses, or the "link" addresses disappears at
> all.
> 
> Unfortunately, it seems that there is no any "stable" scheme to catch the
> issue, but it happens "often enough" in various situations.
> 
> I've wrote a test script (see below), which perform in a loop some trivial
> things over vlans and then shows "ip maddr show". (To run the script further
> just type enter. Ctrl-C to break). I've disabled ipv6 module on the test
> machine to be more clean.
> 
> For me, in the first 5 steps I already catched the issue.
> 
> 
> Instead of the normal situation:
> 
> 1:      lo
>         inet  224.0.0.1
> 2:      eth0
>         link  01:00:5e:00:00:01 users 3
>         inet  224.0.0.1
> 3:      eth0.2
>         link  01:00:5e:00:00:01 users 2
>         inet  224.0.0.1
> 4:      eth0.3
>         link  01:00:5e:00:00:01 users 2
>         inet  224.0.0.1
> 
> 
> I often see:
> 
> 1:      lo
>         inet  224.0.0.1
> 2:      eth0
>         link  01:00:5e:00:00:01
>         inet  224.0.0.1
> 3:      eth0.2
>         link  01:00:5e:00:00:01 users 2
>         inet  224.0.0.1
> 4:      eth0.3
>         inet  224.0.0.1
> 
> 
> or even:
> 
> 1:      lo
>         inet  224.0.0.1
> 2:      eth0
>         inet  224.0.0.1
> 3:      eth0.2
>         inet  224.0.0.1
> 4:      eth0.3
>         inet  224.0.0.1
> 
> at all.
> 
> 
> Sorry that I've tested it on too old kernel (2.6.23), but I hope the test
> script is convenient enough to check whether the issue still present at the
> newest kernels or not.

There's a test case in the bugzilla report.


