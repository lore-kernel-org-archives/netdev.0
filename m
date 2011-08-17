From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [Bugme-new] [Bug 41152] New: kernel 3.0 and above fails to
 handle vlan id 0 (802.1p) packets properly without hardware acceleration
Date: Wed, 17 Aug 2011 12:59:51 +0200
Message-ID: <20110817105950.GA4259@minipsycho.brq.redhat.com>
References: <bug-41152-10286@https.bugzilla.kernel.org/>
 <20110816150918.5b2d7067.akpm@linux-foundation.org>
 <20110817053737.GA1936@minipsycho>
 <4E4B615F.8060403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Mike Auty <mike.auty@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1194 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752943Ab1HQK76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2011 06:59:58 -0400
Content-Disposition: inline
In-Reply-To: <4E4B615F.8060403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 17, 2011 at 08:36:15AM CEST, mike.auty@gmail.com wrote:
>On 17/08/11 06:37, Jiri Pirko wrote:
>> 
>> Hi Mike. May I ask what NIC are you seeing the regression on?
>> It may have something to do with dev->vlangrp and ndo_vlan_add/kill_vid.
>> VID 0 was recently only added by the latter ones. So if driver only
>> depended on dev->vlangrp, 0 was not there. This was changed recently by
>> my "vlan cleanup" patches. It may work for you again on net-next today.
>> 
>
>Hi there,
>
>I'm finding it on the following two NICs:
>
>02:00.0 Ethernet controller: Attansic Technology Corp. L1 Gigabit
>Ethernet Adapter (rev b0)
>
>05:01.0 Network controller [0280]: Broadcom Corporation BCM4306
>802.11b/g Wireless LAN Controller [14e4:4320] (rev 03)
>
>and (on a different machine):
>
>02:00.0 Network controller [0280]: Intel Corporation WiFi Link 6000
>Series [8086:422c] (rev 35)

I just obtained very similar card (8086:422b). Going to look at it right
away.

One more thing. What do you use to generate vlan0 tagged packets? I'm
using pktgen with "vlan_id 0". Would you please try that it behaves the
same for you?
	
>
>The only one I have had any success with is:
>
>00:19.0 Ethernet controller [0200]: Intel Corporation 82577LM Gigabit
>Network Connection [8086:10ea] (rev 05)
>
>Which I assume is because it has actual hardware acceleration.  I may be
>able to put net-next on the Intel Wifi box for testing at some point,
>but I don't know how soon I'll be able to do that.  Please let me know
>whether that would be a worthwhile test, and if so I'll try and get it
>done.  Thanks...
>
>Mike  5:)
>
