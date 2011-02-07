From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 28552] New: ipheth stopped working between
 2.6.35.9 and 2.6.36.2
Date: Mon, 7 Feb 2011 15:07:02 -0800
Message-ID: <20110207150702.c501deb9.akpm@linux-foundation.org>
References: <bug-28552-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, linux-kernel@jmbreuer.net
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39127 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754631Ab1BGXH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 18:07:28 -0500
In-Reply-To: <bug-28552-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 7 Feb 2011 19:24:29 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=28552
> 
>            Summary: ipheth stopped working between 2.6.35.9 and 2.6.36.2
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.36.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: linux-kernel@jmbreuer.net
>         Regression: Yes
> 
> 
> Created an attachment (id=46762)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=46762)
> tcpdump of iPhone tethering attempt in 2.6.36.2
> 
> Overview:
> 
>     Internet connection via iPhone 3G ("USB tethering") no longer works in
> 2.6.36.2; it appears that the packets coming from the iPhone are
> misinterpreted.
> 
> Steps to Reproduce:
> 
>     1) Connect iPhone to computer via USB cable
> 
>     2) Put iPhone in "tethering" mode
> 
> Actual Results:
> 
>     The DHCP client times out trying to obtain a lease.
> 
> Expected Results: 
> 
>     The computer gets IP information via DHCP, and is able to share the
> iPhone's internet connection.
> 
> Build Date & Platform: 
> 
>     2.6.36.2 on x86_64
>     iPhone 3G Firmware 3.1.3
> 
> Additional Builds and Platforms:
> 
>     2.6.35.9 on x86_64 (same hardware) works as expected.
> 
> Additional Information:
> 
>     Attached are 2 tcpdump logs:
>       2.6.36.2-tcpdump.txt in the failure case
>       2.6.35.9-tcpdump.txt, working connection setup
> 
> Comparing the DHCP reply at 19:53:36.581403 (works) to 19:05:05.744666 (fails)
> it appears that 2.6.36.2 misinterprets the data coming from the iPhone, so that
> the failing packet is not recognized as an IP packet / valid DHCP reply.
> 
> The change to ipheth.c itself between 2.6.36 and 2.6.35 seems trivial:
> http://lxr.free-electrons.com/diff/drivers/net/usb/ipheth.c?v=2.6.35;diffval=2.6.36;diffvar=v
> 
> Therefore I'd at first tried copying 2.6.35's ipheth.c into my 2.6.36 tree and
> rebuilding this driver; it appears to fail the same as vanilla 2.6.36 does
> [sorry, no logs - I can repeat this if required].
> 
> This suggests that the failure happens somewhere in either the networking or
> USB layer, not the ipheth.c driver itself.
> 
> I'm happy to perform any additional testing required.
> 

