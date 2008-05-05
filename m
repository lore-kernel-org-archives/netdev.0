From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes
 infrequently
Date: Mon, 5 May 2008 15:55:02 -0700
Message-ID: <20080505155502.3fb16590.akpm@linux-foundation.org>
References: <bug-10600-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>, liblit@acm.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57112 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752050AbYEEWzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 18:55:36 -0400
In-Reply-To: <bug-10600-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat,  3 May 2008 14:55:08 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10600
> 
>            Summary: e1000 updates rx_bytes infrequently
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: liblit@acm.org
> 
> 
> Latest working kernel version: not known
> Earliest failing kernel version: 2.6.24.4 for sure, but it's definitely not new
> Distribution: Fedora 8
> Hardware Environment: Intel 82566DC Gigabit Network Connection
> Software Environment: e1000 driver version 7.3.20-k2-NAPI
> Problem Description:
> 
> The count of received bytes reported in
> "/sys/class/net/eth0/statistics/rx_bytes" updates approximately once every two
> seconds, even when data is streaming in smoothly at 300K/s.  This makes
> transfer rates appear to be quite bursty when viewed in network monitoring
> tools such as the GNOME System Monitor applet.
> 
> Data is not *actually* arriving in once-every-two-second bursts.  For example,
> if I am storing a large download in a file, I am definitely seeing data
> arriving continuously.  It's only the "rx_bytes" count that makes things seem
> bursty because it updates so infrequently.
> 
> Is this frequency tunable in some way?
> 
> Steps to reproduce:
> 
> 1. Run the following command to check the "rx_bytes" count every quarter second
> and highlight any changes from the previous count:
> 
>     watch -d -n 0.25 'cat /sys/class/net/eth0/statistics/rx_bytes'
> 
> 2. Start a large download from a site that you know will give you a good,
> smooth, continuous flow of data.
> 
> 3. Observe that "rx_bytes" only updates about once every two seconds, even
> though data is actually arriving continuously.
> 
> Additional information:
> 
> Originally reported as a GNOME System Monitor bug:
> <http://bugzilla.gnome.org/show_bug.cgi?id=518355>.  The conclusion there was
> that this is a kernel issue and therefore should be transferred here.
> 

Yes, that is a bit obnoxious.

I've noticed that when I'm downloading stuff at home, gkrellm will display
eth0 as consuming 0 kbytes/sec, then 400 kbytes/sec, then 0, then 400 ad
nauseum.  I always assumed that gkrellm was busted.  Perhaps wrongly...



