From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 30092] New: smsc911x.c drops long packets with
 VLAN tags
Date: Tue, 1 Mar 2011 16:15:47 -0800
Message-ID: <20110301161547.13480e90.akpm@linux-foundation.org>
References: <bug-30092-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, weinholt@csbnet.se,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41099 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757517Ab1CBAQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 19:16:17 -0500
In-Reply-To: <bug-30092-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 28 Feb 2011 15:57:14 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=30092
> 
>            Summary: smsc911x.c drops long packets with VLAN tags
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.36.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: weinholt@csbnet.se
>         Regression: No
> 
> 
> The smsc911x.c driver can't receive packets of the maximum MTU if they have a
> 802.1q tag. Testing with ping -s 1500 shows that the frame with the first IP
> segment is dropped.
> 
> The source of the problem is this line at smsc911x.c:1023 (smsc911x_poll):
> 
>   if (unlikely(rxstat & RX_STS_ES_)) {
> 
> The datasheet at
> http://www.smsc.com/media/Downloads_Public/Data_Sheets/9221.pdf describes this
> bit as a logical OR of bits 11, 7, 6 and 1. The problem is that bit 7 is set if
> the packet is longer than 1518 bytes, which is true for the 802.1q tagged
> packets. As a quick and dirty solution, I replaced RX_STS_ES_ with
> (1<<11|1<<6|1<<1), and now 802.1q tagged packets are received just fine.
> 
> This was tested on an IGEPv2, which has a SMSC LAN9221i.
> 

Thanks.  Become famous, get more girls: send us a patch as per
Documentation/SubmittingPatches :)

