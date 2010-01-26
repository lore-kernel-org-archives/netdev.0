From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15091] New: starfire causes kernel BUG when
 interface goes up
Date: Mon, 25 Jan 2010 17:08:16 -0800
Message-ID: <20100125170816.db9435ed.akpm@linux-foundation.org>
References: <bug-15091-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, michael@moffatt.org.nz,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45362 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751396Ab0AZBJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 20:09:24 -0500
In-Reply-To: <bug-15091-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 20 Jan 2010 04:29:20 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=15091
> 
>            Summary: starfire causes kernel BUG when interface goes up
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.32
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: michael@moffatt.org.nz
>         Regression: No
> 
> 
> Created an attachment (id=24651)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=24651)
> ls -l /dev (before crash)
> 
> I formerly used 2.6.20 and 2.6.24 with a couple of starfire 4 port ethernet
> cards. On 2.6.32 the interfaces don't start on boot and when I issue "ifconfig
> ethX up" (where X is a starfire port).
> 
> Sometimes the exception causes the whole kernel to freeze. Sometimes the kernel
> keeps going. On the occasion that the kernel kept going I was able to retrieve
> syslog, which has the full kernel information.
> 
> Note that in syslog, you can see that I inserted a USB memory stick in order to
> copy off the attached files. The kernel oops happens without the USB memory
> stick inserted.
> 
> I can reproduce this at will. At the moment I simply can't use my two four port
> starfire network cards.
> 
> This PC is a root-over-NFS system.
> 

Starfire is triggering the BUG_ON(!test_bit(NAPI_STATE_SCHED,
&n->state)); in napi_enable().

This is a regression somewhere between 2.6.24 and 2.6.32(!).


