From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Bugme-new] [Bug 20772] New: ip= nfsaddrs= stopped working
Date: Thu, 28 Oct 2010 10:51:32 -0400
Message-ID: <54DDEF46-1262-4825-B88A-1F8E92AEC678@oracle.com>
References: <bug-20772-10286@https.bugzilla.kernel.org/> <20101019120938.93622e82.akpm@linux-foundation.org> <20101027223103.GA10484@verge.net.au> <17D7A64D-B275-43EB-AE42-6CA3E65ABCA1@oracle.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, mpetersen@peak6.com
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54343 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758835Ab0J1Owr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 10:52:47 -0400
In-Reply-To: <17D7A64D-B275-43EB-AE42-6CA3E65ABCA1@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 28, 2010, at 10:32 AM, Chuck Lever wrote:

> 
> On Oct 27, 2010, at 6:31 PM, Simon Horman wrote:
> 
>> On Tue, Oct 19, 2010 at 12:09:38PM -0700, Andrew Morton wrote:
>>> 
>>> (switched to email.  Please respond via emailed reply-to-all, not via the
>>> bugzilla web interface).
>>> 
>>> On Tue, 19 Oct 2010 18:20:15 GMT
>>> bugzilla-daemon@bugzilla.kernel.org wrote:
>>> 
>>>> https://bugzilla.kernel.org/show_bug.cgi?id=20772
>>>> 
>>>>          Summary: ip= nfsaddrs= stopped working
>>>>          Product: Networking
>>>>          Version: 2.5
>>>>   Kernel Version: 2.6.33, 2.6.32, 2.6.26
>>>>         Platform: All
>>>>       OS/Version: Linux
>>>>             Tree: Mainline
>>>>           Status: NEW
>>>>         Severity: high
>>>>         Priority: P1
>>>>        Component: IPV4
>>>>       AssignedTo: shemminger@linux-foundation.org
>>>>       ReportedBy: mpetersen@peak6.com
>>>>       Regression: Yes
>>>> 
>>>> 
>>>> I can no longer set a static IP address using either ip= or nfsaddr=,
>>>> ie ip=192.168.0.42:192.168.0.69:255.255.255.0:testhost:eth0:none has no
>>>> effect, and DHCP is still attempted.
>>>> 
>>>> Even if I undefine IP_PNP_DHCP IP_PNP_BOOTP and IP_PNP_RARP in the
>>>> config (but leave IP_PNP,) the kernel seems to ignore the static IP
>>>> settings and try to get a an IP address with DHCP somehow.
>> 
>> Hi,
>> 
>> I believe that the problem is that there is a minor syntax error in the
>> configuration parameter. Specifically there should be two colons between
>> 192.168.0.69 and 255.255.255.0 or between 192.168.0.42 and 192.168.0.69.
>> 
>> As it stands the settings are:
>> 
>> 	my address	192.168.0.42
>> 	server address	192.168.0.69
>> 	gateway		255.255.255.0
>> 	netmask		testhost
>> 	hostname	eth0
>> 	interface	none
>> 
>> I believe it is the interface=none that is killing any IP configuration
>> by the kernel as no such interface exists.
> 
> Did "interface=none" work in 2.6.36 and earlier?

OK, I see that's a dumb question.

I made changes to this area of code in 2.6.37.  I was responding to the bug report above, and not Simon's observation that there was possibly a syntax error.

Sorry for the noise.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




