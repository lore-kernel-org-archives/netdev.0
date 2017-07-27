From: Jonathan Toppins <jtoppins@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: support BCM54616 PHY
Date: Thu, 27 Jul 2017 13:41:08 -0400
Message-ID: <211b5efd-f8d5-cf44-4e0d-dc661c144b7d@redhat.com>
References: <b5d586566a1b523b9be65567b52898e33058a1cf.1500660210.git.>
 <309B89C4C689E141A5FF6A0C5FB2118B8C663B22@ORSMSX101.amr.corp.intel.com>
 <20170727153713.GG18666@lunn.ch>
Reply-To: jtoppins@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Andrew Lunn <andrew@lunn.ch>,
        "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41388 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751122AbdG0RlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Jul 2017 13:41:09 -0400
In-Reply-To: <20170727153713.GG18666@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/27/2017 11:37 AM, Andrew Lunn wrote:
> On Thu, Jul 27, 2017 at 12:40:01AM +0000, Brown, Aaron F wrote:
>>> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@osuosl.org] On Behalf
>>> Of John W. Linville
>>> Sent: Friday, July 21, 2017 11:12 AM
>>> To: netdev@vger.kernel.org
>>> Cc: intel-wired-lan@lists.osuosl.org; John W. Linville
>>> <linville@tuxdriver.com>
>>> Subject: [Intel-wired-lan] [PATCH] igb: support BCM54616 PHY
>>>
>>> The management port on an Edgecore AS7712-32 switch uses an igb MAC,
>>> but
>>> it uses a BCM54616 PHY. Without a patch like this, loading the igb
>>> module produces dmesg output like this:
>>>
>>> [    3.439125] igb: Copyright (c) 2007-2014 Intel Corporation.
>>> [    3.439866] igb: probe of 0000:00:14.0 failed with error -2
>>>
>>> Signed-off-by: John W. Linville <linville@tuxdriver.com>
>>> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> ---
>>>  drivers/net/ethernet/intel/igb/e1000_82575.c   | 6 ++++++
>>>  drivers/net/ethernet/intel/igb/e1000_defines.h | 1 +
>>>  drivers/net/ethernet/intel/igb/e1000_hw.h      | 1 +
>>>  3 files changed, 8 insertions(+)
>>
>> I do not have the specific hardware (Edgecore switch) but as far as regression tests go this works fine.
>> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> 
> Sorry, missed the initial post, so replying to a reply.
> 
> Linux has supported the BCM54616 PHY since April 2015. If the Intel
> drivers used the Linux PHY drivers, you would not of had this problem.
> 
> It would be good if somebody spent the time to migrate these MAC
> drivers to use the common Linux PHY infrastructure.
> 
> 	Andrew
> 

Thank you. This was a point I made in 2015 when I posted the original
patch for igb to support this phy.

http://marc.info/?l=linux-netdev&m=142870703206646&w=2
http://marc.info/?l=linux-netdev&m=142870703806647&w=2
http://marc.info/?l=linux-netdev&m=142870703806648&w=2

http://marc.info/?l=linux-netdev&m=142930225730399&w=2
http://marc.info/?l=linux-netdev&m=142930226230400&w=2

It would be good to accept this patch and then later work to port older
drivers to use phylib.

It might be worthwhile to start beating up on new driver submissions
that don't use phylib.

I recall someone mentioning that there were plans to have phylib support
[Q]SFP[+] modules as well. I am very interested in that work, if someone
has patches/plans I would like to take a look.

-Jon
