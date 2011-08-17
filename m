From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [Bugme-new] [Bug 41152] New: kernel 3.0 and above fails to
 handle vlan id 0 (802.1p) packets properly without hardware acceleration
Date: Wed, 17 Aug 2011 19:50:43 +0200
Message-ID: <20110817175041.GA2592@minipsycho>
References: <bug-41152-10286@https.bugzilla.kernel.org/>
 <20110816150918.5b2d7067.akpm@linux-foundation.org>
 <20110817053737.GA1936@minipsycho>
 <4E4B615F.8060403@gmail.com>
 <20110817105950.GA4259@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Mike Auty <mike.auty@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24316 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751045Ab1HQRux (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2011 13:50:53 -0400
Content-Disposition: inline
In-Reply-To: <20110817105950.GA4259@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 17, 2011 at 12:59:51PM CEST, jpirko@redhat.com wrote:
>Wed, Aug 17, 2011 at 08:36:15AM CEST, mike.auty@gmail.com wrote:
>>On 17/08/11 06:37, Jiri Pirko wrote:
>>> 
>>> Hi Mike. May I ask what NIC are you seeing the regression on?
>>> It may have something to do with dev->vlangrp and ndo_vlan_add/kill_vid.
>>> VID 0 was recently only added by the latter ones. So if driver only
>>> depended on dev->vlangrp, 0 was not there. This was changed recently by
>>> my "vlan cleanup" patches. It may work for you again on net-next today.
>>> 
>>
>>Hi there,
>>
>>I'm finding it on the following two NICs:
>>
>>02:00.0 Ethernet controller: Attansic Technology Corp. L1 Gigabit
>>Ethernet Adapter (rev b0)
>>
>>05:01.0 Network controller [0280]: Broadcom Corporation BCM4306
>>802.11b/g Wireless LAN Controller [14e4:4320] (rev 03)
>>
>>and (on a different machine):
>>
>>02:00.0 Network controller [0280]: Intel Corporation WiFi Link 6000
>>Series [8086:422c] (rev 35)
>
>I just obtained very similar card (8086:422b). Going to look at it right
>away.
>
>One more thing. What do you use to generate vlan0 tagged packets? I'm
>using pktgen with "vlan_id 0". Would you please try that it behaves the
>same for you?

I'm using following pktgen script:
http://pastebin.com/E3f4R8XY

On rx site with Intel wireless card I use following stap script to
observe incoming packets:
http://pastebin.com/VeXLhauu

All is looking good there. What do you use to look at incoming packets?

Jirka

>	
>>
>>The only one I have had any success with is:
>>
>>00:19.0 Ethernet controller [0200]: Intel Corporation 82577LM Gigabit
>>Network Connection [8086:10ea] (rev 05)
>>
>>Which I assume is because it has actual hardware acceleration.  I may be
>>able to put net-next on the Intel Wifi box for testing at some point,
>>but I don't know how soon I'll be able to do that.  Please let me know
>>whether that would be a worthwhile test, and if so I'll try and get it
>>done.  Thanks...
>>
>>Mike  5:)
>>
