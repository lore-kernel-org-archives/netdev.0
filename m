From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Wed, 29 Jun 2011 14:51:35 -0700
Message-ID: <20110629145135.5179fb0c.akpm@linux-foundation.org>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, alexey.zaytsev@gmail.com
To: netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54396 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751889Ab1F2VwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 17:52:09 -0400
In-Reply-To: <bug-38102-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 23 Jun 2011 17:33:54 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=38102
> 
>            Summary: BUG kmalloc-2048: Poison overwritten
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 3.0.0-rc4

Looks like a 2.6.38->2.6.39 regression, perhaps a memory scribble in b44.

>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: alexey.zaytsev@gmail.com
>         Regression: Yes
> 
> 
> Created an attachment (id=63342)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=63342)
> dmesg
> 
> Hi.
> 
> Getting a bunch of kmalloc-2048 use-after-free. First noticed in 2.6.39, but
> also present in 3.0.0-rc4.
> 
> I guess it might be driver-related, as the problem went unnoticed for a whole
> release. The device is
> 
> 02:0e.0 Ethernet controller: Broadcom Corporation BCM4401-B0 100Base-TX (rev
> 02)
>     Subsystem: Hewlett-Packard Company NX7300 laptop
>     Flags: bus master, fast devsel, latency 64, IRQ 16
>     Memory at f4108000 (32-bit, non-prefetchable) [size=8K]
>     Capabilities: [40] Power Management version 2
>     Kernel driver in use: b44
> 
> 
> Config and dmesg attached. I'm noticing the problem when ssh'ing to an illumos
> box, as ssh would disconnect when the illumos build process spews the cached
> build-logs. But the problem might be unrelated, as one corruption contains http
> data. It also seems is hard to trigger any other traffic, even from the same
> box.
> 


