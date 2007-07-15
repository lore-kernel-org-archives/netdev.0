From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [Bugme-new] [Bug 8756] New: Route advmss copied to ALL routes
 when interface MTU changes
Date: Sun, 15 Jul 2007 09:07:35 +0100
Message-ID: <4699D5C7.2090906@simon.arlott.org.uk>
References: <bug-8756-10286@http.bugzilla.kernel.org/> <20070714214831.d9def8c6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:46224 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754066AbXGOIHj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jul 2007 04:07:39 -0400
In-Reply-To: <20070714214831.d9def8c6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/07/07 05:48, Andrew Morton wrote:
> On Sat, 14 Jul 2007 15:34:31 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=8756
> 
> It is unclear which kernel version this applies to?

Linus' 2.6 tree, as of Mon Jul 9 15:50:56 2007 -0700

For some reason it says "Version: 2.5" on the email and "Version: " on
the website...

> 
>>            Summary: Route advmss copied to ALL routes when interface MTU
>>                     changes
>>            Product: Networking
>>            Version: 2.5
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: IPV6
>>         AssignedTo: yoshfuji@linux-ipv6.org
>>         ReportedBy: bugzilla@fire.lp0.eu
>> 
>> 
>> Steps to reproduce:
>> 1. Have multiple network devices and routes for them with standard (low, i.e.
>> 1500) MTUs and default ADVMSS (e.g. 1440)
>> 2. Change the MTU on one of them to something high (e.g. 7200)
>> 3. The ADVMSS is incorrectly set for ALL routes based on the new MTU of the
>> interface that changed.
>> 
>> Note: if addrconf is running then the ADVMSS will be reset on the next RA, so
>> this will impede attempts to reproduce.
>> 
>> # ip -6 r
>> fe80::/64 dev sit0  metric 256  expires 4481744sec mtu 1480 advmss 1440
>> hoplimit 4294967295
>> fe80::/64 dev ppp0  metric 256  expires 19071345sec mtu 1500 advmss 1440
>> hoplimit 4294967295
>> fe80::/64 dev eth0  metric 256  expires 19072430sec mtu 1500 advmss 1440
>> hoplimit 4294967295
>> default dev ppp0  metric 1024  expires 19071347sec mtu 1500 advmss 1440
>> hoplimit 4294967295
>> 
>> # ifconfig eth0 mtu 7200
>> 
>> # ip -6 r
>> fe80::/64 dev sit0  metric 256  expires 4481732sec mtu 1480 advmss 7140
>> hoplimit 4294967295 <-- wrong
>> fe80::/64 dev ppp0  metric 256  expires 19071334sec mtu 1500 advmss 7140
>> hoplimit 4294967295 <-- wrong
>> fe80::/64 dev eth0  metric 256  expires 19072419sec mtu 7200 advmss 7140
>> hoplimit 4294967295 <-- correct
>> 
>> Explicitly setting the MTU on these other routes (although this is not possible
>> without having to add another route due to bug 8755) automatically sets ADVMSS
>> appropriately.
>> 


-- 
Simon Arlott
