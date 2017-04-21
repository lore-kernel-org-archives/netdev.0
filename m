From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 net-next 5/8] net/ncsi: Dump NCSI packet statistics
Date: Thu, 20 Apr 2017 17:26:14 -0700
Message-ID: <0289f0b2-36a8-f4a0-ef15-808aa66528fa@gmail.com>
References: <1492498295-14385-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1492498295-14385-6-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170420.132103.454438573956782815.davem@davemloft.net>
 <20170420233812.GA7223@gwshan>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com, kubakici@wp.pl
To: Gavin Shan <gwshan@linux.vnet.ibm.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35445 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947939AbdDUA0S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 20:26:18 -0400
Received: by mail-qt0-f193.google.com with SMTP id o36so9952180qtb.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 17:26:18 -0700 (PDT)
In-Reply-To: <20170420233812.GA7223@gwshan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2017 04:38 PM, Gavin Shan wrote:
> On Thu, Apr 20, 2017 at 01:21:03PM -0400, David Miller wrote:
>> From: Gavin Shan <gwshan@linux.vnet.ibm.com>
>> Date: Tue, 18 Apr 2017 16:51:32 +1000
>>
>>> This creates /sys/kernel/debug/ncsi/<eth0>/stats to dump the NCSI
>>> packets sent and received over all packages and channels. It's useful
>>> to diagnose NCSI problems, especially when NCSI packages and channels
>>> aren't probed properly. The statistics can be gained from debugfs file
>>> as below:
>>>
>>>  # cat /sys/kernel/debug/ncsi/eth0/stats
>>
>> There is no reason you cannot use ethtool statistics to provide this
>> information to the user.
>>
> 
> It can be dumped by ethtool, but it's more reasonable to dump them
> through debugfs for couple of reasons: (1) ethtool usually dumps
> statistics collected by hardware, but this debugfs file dumps the
> statistics of packets seen (collected) by software. They are different
> things. Note that NCSI channel collects statistics in hardware and it's
> not exposed or dumped by this patchset. They are candidates for ethtool.
> (2) To expose this through ethtool relies on the availability of the tool.
> It's nicer not to depend on it. (3) This interface can be used to check
> the debug packet has been sent successfully through /sys/kernel/debug/ncsi/eth0/pkt,
> dumping the statistics through debugfs make this (debugging) mechanism
> consistent.

Can't you create a ncsi folder under /sys/class/net/eth0/nsci/ and then
put your stats in there? That would at least look slightly consistent
with what is already existing for the non-NC-SI networking stack.
-- 
Florian
