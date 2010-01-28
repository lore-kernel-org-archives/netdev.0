From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15147] New: phylib: no re-negotiation after
 link partner abilities changed
Date: Wed, 27 Jan 2010 16:48:33 -0800
Message-ID: <20100127164833.f0c96ded.akpm@linux-foundation.org>
References: <bug-15147-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Haavard Skinnemoen <hskinnemoen@atmel.com>, dannybaumann@web.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39284 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751610Ab0A1Asi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 19:48:38 -0500
In-Reply-To: <bug-15147-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 26 Jan 2010 16:24:35 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=15147
> 
>            Summary: phylib: no re-negotiation after link partner abilities
>                     changed
>            Product: Drivers
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: dannybaumann@web.de
>         Regression: No
> 
> 
> E.g. with the macb driver, which uses phylib, there is no link anymore when the
> link partner changes its abilities. This is because no autonegotiation is done
> again on link changes and hence the LPA register is not updated.
> 
> Steps for reproduction:
> - Connect a 10/100 device to a 10/100 switch, configure switch port to 100Full
> - Enable interface, link will be present
> - Configure device to 10Full, link will be lost
> - Configure switch to 10Full
> 
> Result:
> Link should be present at that point, but isn't ... debug messages in
> genphy_read_status show that lpa is still at 0x4101 (100Full).
> 
> Note that all that is on an AT91SAM9G20 board (hence macb driver) with a
> Dawicom 9161 PHY connected to its Ethernet port, but AFAICT all phylib enabled
> drivers should suffer from this.
> 

>From the above it appears that this is a regression.

Can you tell us which kernel version(s) were OK and which are not?

Thanks.
