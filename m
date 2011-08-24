From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [Bugme-new] [Bug 40572] New: Intel Gigabit Ethernet 82576 50%
 packet loss after reboot
Date: Wed, 24 Aug 2011 13:25:42 -0700
Message-ID: <4E555E46.9040009@intel.com>
References: <bug-40572-10286@https.bugzilla.kernel.org/> <20110823143053.832c1aaa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	bugme-daemon@bugzilla.kernel.org, vojcik@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57268 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751194Ab1HXU3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 16:29:06 -0400
In-Reply-To: <20110823143053.832c1aaa.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2011 02:30 PM, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Fri, 5 Aug 2011 07:07:05 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=40572
>>
>>             Summary: Intel Gigabit Ethernet 82576 50% packet loss after
>>                      reboot
>>             Product: Drivers
>>             Version: 2.5
>>      Kernel Version: 3.0
>>            Platform: All
>>          OS/Version: Linux
>>                Tree: Mainline
>>              Status: NEW
>>            Severity: blocking
>>            Priority: P1
>>           Component: Network
>>          AssignedTo: drivers_network@kernel-bugs.osdl.org
>>          ReportedBy: vojcik@gmail.com
>>          Regression: No
> I'll change this to "yes".
>
>> Hi,
>>
>> I have strange problem with Intel dualport Gigabit ehternet card.
>> Problem appears after 3rd - 5th reboot.
>>
>> If you ping or make any network traffic you get 50% packet loss. No error
>> messages in logs.
>> When you make reboot all is ok in next few reboots.
>>
>> We have eliminated network problems like switches, cables etc. It's software
>> related.
>>
>> It looks like in kernel 2.6.37 we have the same problem but in 2.6.28.6
>> everything looks fine.
>>
>> I attach some files for additional information
This type of issue is typically a sign of a hardware problem.  I would 
recommend doing an lspci -vvv for the device in both the working and the 
non-working cases to see if there is any difference between the two.

One thing we have seen in the past is an issue where the PCIe will not 
link at x4 in all cases and will sometimes link at only x1.  When this 
occurs the device does not have enough PCIe bandwidth to handle heavy 
workloads.  You might want to try either reseating the network adapter 
into the slot or moving it from one PCIe slot to another in the system 
as it is possible the PCIe slot it is in may have an issue with one ore 
more of the PCIe lanes.

Thanks,

Alex
