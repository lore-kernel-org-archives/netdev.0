From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Fw: [Bug 54601] New: PPP regression on 3.2.39 stop work need
 restart server ont version 3.2.21 not found this problem.
Date: Mon, 4 Mar 2013 22:48:37 +0000
Message-ID: <20130304224837.GX9079@decadent.org.uk>
References: <20130301084705.4169c429@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, micron10@gmail.com,
	Eric Dumazet <edumazet@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40639 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758655Ab3CDWsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 17:48:42 -0500
Content-Disposition: inline
In-Reply-To: <20130301084705.4169c429@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 01, 2013 at 08:47:05AM -0800, Stephen Hemminger wrote:
> 
> 
> Begin forwarded message:
> 
> Date: Fri, 1 Mar 2013 01:24:14 -0800
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 54601] New: PPP regression on 3.2.39 stop work need restart server ont version 3.2.21 not found this problem.
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=54601
> 
>            Summary: PPP regression on 3.2.39 stop work need restart server
>                     ont version 3.2.21 not found this problem.
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.2.39
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: micron10@gmail.com
>         Regression: Yes
> 
> 
> Hi
> watch a problem with PPP after upgrade to version 3.2.39 ppp service stop work
> 2 hours after start with this crash :
> 
> [79619.180026] unregister_netdevice: waiting for ppp618 to become free. Usage
> count = 562
[...]
> [79862.540040] unregister_netdevice: waiting for ppp618 to become free. Usage
> count = 30
> [79872.680037] unregister_netdevice: waiting for ppp618 to become free. Usage
> count = 9
[...]

So there are many references left to the device, which slowly go away
(very slowly, about 2 per second).  Maybe there are skbs in a queue somewhere
that still refer to the PPP device.

Since this a regression between 3.2.21 and 3.2.29, it might have been
introduced by:

commit 73a3346556281fd56f39f0a9475249e5039d8807
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu Jun 14 06:42:44 2012 +0000

    net: remove skb_orphan_try()
    
    commit 62b1a8ab9b3660bb820d8dfe23148ed6cda38574 upstream.

But this is a bit of a guess.  And I don't think that this change
would do more than expose/exacerbate a bug that already existed.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
