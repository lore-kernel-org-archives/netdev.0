From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: support BCM54616 PHY
Date: Thu, 27 Jul 2017 10:57:36 -0700
Message-ID: <76c8ea56-8e4e-a85c-abe5-695b46c99308@gmail.com>
References: <b5d586566a1b523b9be65567b52898e33058a1cf.1500660210.git.>
 <309B89C4C689E141A5FF6A0C5FB2118B8C663B22@ORSMSX101.amr.corp.intel.com>
 <20170727153713.GG18666@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Andrew Lunn <andrew@lunn.ch>,
        "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33667 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751539AbdG0R5m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 13:57:42 -0400
Received: by mail-wm0-f68.google.com with SMTP id q189so13499687wmd.0
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 10:57:41 -0700 (PDT)
In-Reply-To: <20170727153713.GG18666@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/27/2017 08:37 AM, Andrew Lunn wrote:
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

I suspect there is a design pattern within the Intel drivers to share as
much low-level code as possible between OSes and only have some
Linux-ism where necessary (e.g: net_device, ethtool etc.).

PHY code is a pain in general, especially if you are serious about
testing interoperability (which is where you can spend tons of $$$ with
little reward but just say: yes it works), so it may make sense to share
it across different OSes.

I too, wish there was more sharing, but considering that this works for
the Intel driver, there is little incentive in doing this I suppose...
-- 
Florian
