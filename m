From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 28512] New: IPv6 SLAAC address preferred over
 static one as source address
Date: Mon, 7 Feb 2011 15:20:48 -0800
Message-ID: <20110207152048.22c51184.akpm@linux-foundation.org>
References: <bug-28512-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, ghen@telenet.be
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36749 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755079Ab1BGXVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 18:21:44 -0500
In-Reply-To: <bug-28512-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 7 Feb 2011 16:15:16 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=28512
> 
>            Summary: IPv6 SLAAC address preferred over static one as source
>                     address
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.36
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: ghen@telenet.be
>         Regression: No
> 
> 
> Linux IPv6 source address selection rules are described here:
> http://www.davidc.net/networking/ipv6-source-address-selection-linux
> 
> In case of a tie, "Linux chooses to use the latest address added".
> 
> A very common tie is where a host has a SLAAC (Stateless address
> auto-configuration) address as well as one or more statically assigned ones in
> the same /64.  The SLAAC address will almost always be the most recently
> "added" one, as it is renewed with every Router Advertisement on the network,
> and there will be a tie for all other rules.
> 
> As a consequence, the kernel chooses this address by default for outgoing
> connections.  This is usually not the preferred scenario; the static address
> will more likely have proper reverse DNS, be configured in ACL's, etc.
> 
> This has been discussed on the ipv6-ops mailing list
> (ipv6-ops@lists.cluenet.de), and a better suggestion for a tie-breaker came
> out: the preferred lifetime of the address.
> 
> SLAAC addresses will have a limited preferred lifetime (as defined by the
> router), static addresses will usually have an unlimited preferred lifetime
> (0).  So it makes a lot of sense to take this preferred lifetime into account
> for source address selection (how is it otherwise "preferred"?).
> 
> This could be added as rule #9 before using the most recently added as a final
> tie breaker?
> 
> Geert

