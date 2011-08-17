From: Mike Auty <mike.auty@gmail.com>
Subject: Re: [Bugme-new] [Bug 41152] New: kernel 3.0 and above fails to handle
 vlan id 0 (802.1p) packets properly without hardware acceleration
Date: Wed, 17 Aug 2011 07:36:15 +0100
Message-ID: <4E4B615F.8060403@gmail.com>
References: <bug-41152-10286@https.bugzilla.kernel.org/> <20110816150918.5b2d7067.akpm@linux-foundation.org> <20110817053737.GA1936@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:45985 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750721Ab1HQGgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 02:36:20 -0400
In-Reply-To: <20110817053737.GA1936@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/08/11 06:37, Jiri Pirko wrote:
> 
> Hi Mike. May I ask what NIC are you seeing the regression on?
> It may have something to do with dev->vlangrp and ndo_vlan_add/kill_vid.
> VID 0 was recently only added by the latter ones. So if driver only
> depended on dev->vlangrp, 0 was not there. This was changed recently by
> my "vlan cleanup" patches. It may work for you again on net-next today.
> 

Hi there,

I'm finding it on the following two NICs:

02:00.0 Ethernet controller: Attansic Technology Corp. L1 Gigabit
Ethernet Adapter (rev b0)

05:01.0 Network controller [0280]: Broadcom Corporation BCM4306
802.11b/g Wireless LAN Controller [14e4:4320] (rev 03)

and (on a different machine):

02:00.0 Network controller [0280]: Intel Corporation WiFi Link 6000
Series [8086:422c] (rev 35)

The only one I have had any success with is:

00:19.0 Ethernet controller [0200]: Intel Corporation 82577LM Gigabit
Network Connection [8086:10ea] (rev 05)

Which I assume is because it has actual hardware acceleration.  I may be
able to put net-next on the Intel Wifi box for testing at some point,
but I don't know how soon I'll be able to do that.  Please let me know
whether that would be a worthwhile test, and if so I'll try and get it
done.  Thanks...

Mike  5:)

