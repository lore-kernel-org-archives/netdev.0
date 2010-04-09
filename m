From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: net-next: 2.6.34-rc1 regression: panic when running diagnostic
 on interface with IPv6
Date: Fri, 9 Apr 2010 17:00:31 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FE4FCD423@rrsmsx501.amr.corp.intel.com>
References: <EA929A9653AAE14F841771FB1DE5A1365FE4E2E26C@rrsmsx501.amr.corp.intel.com>
 <20100405.161221.159637463.davem@davemloft.net>
 <EA929A9653AAE14F841771FB1DE5A1365FE4E2E334@rrsmsx501.amr.corp.intel.com>
 <20100405.165317.89399272.davem@davemloft.net>
 <20100409151916.633fc58c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50373 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754140Ab0DIXAd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 19:00:33 -0400
In-Reply-To: <20100409151916.633fc58c@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 05 Apr 2010 16:53:17 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
>> Date: Mon, 5 Apr 2010 17:50:38 -0600
>> 
>>> David Miller wrote:
>>>> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
>>>> Date: Mon, 5 Apr 2010 17:03:56 -0600
>>>> 
>>>>> David Miller wrote:
>>>>>> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
>>>>>> Date: Tue, 23 Mar 2010 12:28:08 -0600
>>>>>> 
>>>>>>> Bisecting points to this patch:
>>>>>>> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=84e8b803f1e16f3a2b8b80f80a63fa2f2f8a9be6
>>>>>>> 
>>>>>>> And I confirmed that the issue goes away after reverting it.
>>>>>>> 
>>>>>>> Steps to reproduce:
>>>>>>> 1. Load the driver and configure IPv6 address.
>>>>>>> 2. Run ethtool diag:
>>>>>>> ethtool -t eth0
>>>>>>> 
>>>>>>> 3. If this doesn't brake it try again, or just do ifdown/up.
>>>>>>> Other operations on the interface will eventually panic the
>>>>>>> system: 
>>>>>> 
>>>>>> Stephen please fix this, thanks.
>>>>> 
>>>>> Just FYI - I still see this issue with latest pull from net-2.6.
>>>> 
>>>> It's net-next-2.6 that introduced the problem and has the follow-on
>>>> fixes, not net-2.6
>>> 
>>> Same in net-next:
> 
> Are you using the standard e1000e driver from net-next or some other
> Intel version.  It works fine on my e1000e doing online or offline
> tests.
> 
> # ethtool -i eth4
> driver: e1000e
> version: 1.0.2-k2
> firmware-version: 5.11-2
> bus-info: 0000:03:00.0
> 
> Do you have any other suggestions (script or anything), that makes
> the problem happen.

Stock net-next, nothing external. 

I played with it some more to get the exact commands. Looks like the following should repro it:

ifconfig eth0 inet6 add fec0::1509/112 up
ethtool -t eth0
ifconfig eth0 inet6 del fec0::1509/112

Thanks,
Emil