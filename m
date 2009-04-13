From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13084] New: page allocation failure. order:0,
 mode:0x20
Date: Mon, 13 Apr 2009 12:42:28 -0700
Message-ID: <20090413124228.be31e9f3.akpm@linux-foundation.org>
References: <bug-13084-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: reeve.yang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36015 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752026AbZDMTrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 15:47:12 -0400
In-Reply-To: <bug-13084-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 13 Apr 2009 19:27:27 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13084
> 
>            Summary: page allocation failure. order:0, mode:0x20
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.17.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Page Allocator
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: reeve.yang@gmail.com
>         Regression: No
> 
> 
> Created an attachment (id=20964)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=20964)
> kernel config file.
> 
> The system is Intel Xeon Quad core with 8G physical RAM. When it's under UPD
> loads, e.g., DNS queries, the box is stuck in terms it cannot be pinged or
> login. By checking syslog, I'm seeing following trace back from various
> dameon/processes. The network controller is E1000 82571 with NAPI enabled in
> kernel.
>
> page allocation failure. order:0, mode:0x20

This is very common.  e1000 attempts to do large memory allocations
from within interrupt context and the page allocator cannot satisfy the
allocation and is not allowed to do the necessary work to make the
allocation attempt succeed.  It's the same with all net drivers, but
e1000 is especially prone, apparently because of hardware suckiness.

However the networking stack should just drop the packet and the system
will recover.

You report is unclear.  Yes, the machine wedges up under the UDP load. 
But does it recover when the other machine stops spraying UDP packets
at this machine?  It _should_ recover.  If it does not, we have a bug
somewhere.

The usual workaround for these problems is to increase the value in
/proc/sys/vm/min_free_kbytes.

2.6.17 is fairly old.  If we need to do additional work on this report
then we'll be asking you to test something more recent - ideally
2.6.29.

Thanks.

