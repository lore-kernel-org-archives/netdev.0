From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 32832] New: shutdown(2) does not fully shut
 down socket any more
Date: Tue, 12 Apr 2011 16:15:56 -0700
Message-ID: <20110412161556.0641bdae.akpm@linux-foundation.org>
References: <bug-32832-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, kees@outflux.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38972 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756330Ab1DLXQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 19:16:30 -0400
In-Reply-To: <bug-32832-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 6 Apr 2011 22:42:38 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=32832

There is a tescase attached to this bugzilla report.

>            Summary: shutdown(2) does not fully shut down socket any more
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.38
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: kees@outflux.net
>         Regression: Yes
> 
> 
> In 2.6.35 and earlier, shutdown(2) will fully remove a socket. This does not
> appear to be true any more and is causing software to misbehave.
> 
> 2.6.35:
> $ ./testcase
> parent: 5957
> before:
> tcp        0      0 0.0.0.0:12345           0.0.0.0:*               LISTEN     
> after:
> child: 5961
> $ ./testcase
> parent: 6001
> before:
> tcp        0      0 0.0.0.0:12345           0.0.0.0:*               LISTEN     
> after:
> child: 6002
> 
> 2.6.38:
> $ ./testcase
> parent: 1138
> before:
> tcp        0      0 0.0.0.0:12345           0.0.0.0:*               LISTEN     
> after:
> child: 1142
> $ ./testcase
> bind: Address already in use
> 
> The listener doesn't show up in netstat any more, but as long as the child
> process is running, the socket is unavailable. It is as if the shutdown(2)
> behavior has partially reverted to close(2) behavior (but in the case of using
> close(2), the child's socket would remain visible in netstat).
> 


