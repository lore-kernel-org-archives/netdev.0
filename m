From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [Bugme-new] [Bug 41152] New: kernel 3.0 and above fails to
 handle vlan id 0 (802.1p) packets properly without hardware acceleration
Date: Wed, 17 Aug 2011 07:37:38 +0200
Message-ID: <20110817053737.GA1936@minipsycho>
References: <bug-41152-10286@https.bugzilla.kernel.org/>
 <20110816150918.5b2d7067.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	mike.auty@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43990 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813Ab1HQFiu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2011 01:38:50 -0400
Content-Disposition: inline
In-Reply-To: <20110816150918.5b2d7067.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 17, 2011 at 12:09:18AM CEST, akpm@linux-foundation.org wrote:
>
>(switched to email.  Please respond via emailed reply-to-all, not via the
>bugzilla web interface).
>
>On Sun, 14 Aug 2011 12:48:16 GMT
>bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=41152
>> 
>>            Summary: kernel 3.0 and above fails to handle vlan id 0
>>                     (802.1p) packets properly without hardware
>>                     acceleration
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: 3.0
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Other
>>         AssignedTo: acme@ghostprotocols.net
>>         ReportedBy: mike.auty@gmail.com
>>         Regression: Yes
>> 
>> 
>> Hi there,
>> 
>> I recently found that packets tagged with a vlan id of 0 are no longer received
>> on the main interface.  There were no dmesg entries on the dropped packets.  I
>> attempted to setup a vlan 0 interface and configure it, but couldn't
>> successfully route traffic to the device.  I can recreate this on two of the
>> three networking devices I have, my guess is that the third does successfully
>> handle hardware acceleration of vlan tags. 
>> 
>> After a bisection this appears to be related to commit
>> bcc6d47903612c3861201cc3a866fb604f26b8b2, which seems to try to merge the
>> non-hardware accelerated and hardware accelerated code paths for handling
>> vlans.  In the process, it appears vlan id 0 (802.1p) packets are no longer
>> handled correctly.
>> 
>> Unfortunately I don't know the code paths well enough to figure out what's
>> going wrong, but I'd be happy to provide more information, run tests or try out
>> patches if it would help, just let me know.  Thanks...  5:)
>> 
>> Mike  5:)

Hi Mike. May I ask what NIC are you seeing the regression on?
It may have something to do with dev->vlangrp and ndo_vlan_add/kill_vid.
VID 0 was recently only added by the latter ones. So if driver only
depended on dev->vlangrp, 0 was not there. This was changed recently by
my "vlan cleanup" patches. It may work for you again on net-next today.


Jirka
>
