From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Fw: [Bug 15907] New: IP_ADD_SOURCE_MEMBERSHIP after IP_ADD_MEMBERSHIP
 join on same multicast-group dont return EINVAL
Date: Wed, 5 May 2010 10:09:30 -0700
Message-ID: <OFD4CF7550.98F2D787-ON8825771A.005CD3AE-8825771A.005E4045@us.ibm.com>
References: <20100505082138.6cb93aa1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:38022 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751432Ab0EERKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 13:10:13 -0400
In-Reply-To: <20100505082138.6cb93aa1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This particular failure  may be  just a matter of translating the
EADDRINUSE check in IP_ADD_SOURCE_MEMBERSHIP to
return EINVAL rather than ignoring it. The more general change of
segregating SSM and ASM should go further than that (e.g., a boolean
to tell you which way the membership was added and checking in
all the operations).

The code predates this informational RFC and allows you to
change back and forth between ASM and SSM where it makes
sense (a more liberal interpretation).

Of course, if existing applications are mixing them already, they
would break, and I'm not sure I agree it's a good thing to have
to destroy an existing membership and recreate it if you want to
switch from ASM to SSM.

I can look at this, but not for a few days at least; can review if
someone else does before I do.

                                        +-DLS


netdev-owner@vger.kernel.org wrote on 05/05/2010 08:21:38 AM:

> 
> 
> Begin forwarded message:
> 
> Date: Wed, 5 May 2010 09:48:40 GMT
> From: bugzilla-daemon@bugzilla.kernel.org
> To: shemminger@linux-foundation.org
> Subject: [Bug 15907] New: IP_ADD_SOURCE_MEMBERSHIP after 
IP_ADD_MEMBERSHIP 
> join on same multicast-group dont return EINVAL
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=15907
> 
>            Summary: IP_ADD_SOURCE_MEMBERSHIP after IP_ADD_MEMBERSHIP 
join
>                     on same multicast-group dont return EINVAL
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.34-rc6
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: mail@fholler.de
>         Regression: No
> 
> 
> Created an attachment (id=26225)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=26225)
> asm+ssm join test program
> 
> When an SSM IP_ADD_SOURCE_MEMBERSHIP is done after an ASM 
IP_ADD_MEMBERSHIP
> join on the same group(& same interface) the setsockopt operation should 
return
> EINVAL.
> 
> The linux implementation returns successfull
> 
> 
> 
> https://www3.tools.ietf.org/html/rfc3678#section-4.1.3
> 
> I attached an simple C test program.
> 
> -- 
> Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are the assignee for the bug.
> 
> 
> -- 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

