From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 net-next 5/8] net/ncsi: Dump NCSI packet statistics
Date: Thu, 20 Apr 2017 17:59:27 -0700
Message-ID: <6b310c50-bab4-b5a7-0317-5a430c55917a@gmail.com>
References: <1492498295-14385-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1492498295-14385-6-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170420.132103.454438573956782815.davem@davemloft.net>
 <20170420233812.GA7223@gwshan>
 <0289f0b2-36a8-f4a0-ef15-808aa66528fa@gmail.com>
 <20170421004435.GA18727@gwshan>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        joe@perches.com, kubakici@wp.pl
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35239 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S948291AbdDUA7e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 20:59:34 -0400
Received: by mail-wr0-f195.google.com with SMTP id l44so10068407wrc.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 17:59:33 -0700 (PDT)
In-Reply-To: <20170421004435.GA18727@gwshan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2017 05:44 PM, Gavin Shan wrote:
> On Thu, Apr 20, 2017 at 05:26:14PM -0700, Florian Fainelli wrote:
>> On 04/20/2017 04:38 PM, Gavin Shan wrote:
>>> On Thu, Apr 20, 2017 at 01:21:03PM -0400, David Miller wrote:
>>>> From: Gavin Shan <gwshan@linux.vnet.ibm.com>
>>>> Date: Tue, 18 Apr 2017 16:51:32 +1000
>>>>
>>>>> This creates /sys/kernel/debug/ncsi/<eth0>/stats to dump the NCSI
>>>>> packets sent and received over all packages and channels. It's useful
>>>>> to diagnose NCSI problems, especially when NCSI packages and channels
>>>>> aren't probed properly. The statistics can be gained from debugfs file
>>>>> as below:
>>>>>
>>>>>  # cat /sys/kernel/debug/ncsi/eth0/stats
>>>>
>>>> There is no reason you cannot use ethtool statistics to provide this
>>>> information to the user.
>>>>
>>>
>>> It can be dumped by ethtool, but it's more reasonable to dump them
>>> through debugfs for couple of reasons: (1) ethtool usually dumps
>>> statistics collected by hardware, but this debugfs file dumps the
>>> statistics of packets seen (collected) by software. They are different
>>> things. Note that NCSI channel collects statistics in hardware and it's
>>> not exposed or dumped by this patchset. They are candidates for ethtool.
>>> (2) To expose this through ethtool relies on the availability of the tool.
>>> It's nicer not to depend on it. (3) This interface can be used to check
>>> the debug packet has been sent successfully through /sys/kernel/debug/ncsi/eth0/pkt,
>>> dumping the statistics through debugfs make this (debugging) mechanism
>>> consistent.
>>
>> Can't you create a ncsi folder under /sys/class/net/eth0/nsci/ and then
>> put your stats in there? That would at least look slightly consistent
>> with what is already existing for the non-NC-SI networking stack.
> 
> Do you think it's good place to have /sys/class/net/eth0/ncsi/pkt?
> Note this file accepts commands to send NCSI comands and dumps the
> corresponding response on read. Also, it's a debugging interface
> and disabled (invisible) for the most time. I think all directories
> and files in /sys/class/net/eth0/ should be visible and the structure
> is stable all the time.

Statistics should not be debugging features having them all the time is
invaluable, so in that regard they could probably be part of a sysfs
interface of some kind. If this "pkt" file is special, then yes, maybe
debugfs is appropriate here.

It sounds like you may also want to consider doing a NC-SI generic
netlink family at some point, because chances are that are you going to
export more and more information over time, just like there could be
additional commands/actions to be performed as well as asynchronous
events. Netlink is great for that, downside is that you have to write a
custom user-space tool (or extend iproute2).
-- 
Florian
