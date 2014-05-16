From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 1/4] net: Find the nesting level of a given device
 by type.
Date: Fri, 16 May 2014 14:34:21 -0400
Message-ID: <53765A2D.8050205@redhat.com>
References: <1400260697-32601-1-git-send-email-vyasevic@redhat.com>	 <1400260697-32601-2-git-send-email-vyasevic@redhat.com> <1400261568.7973.225.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dingtianhong@huawei.com, kaber@trash.net,
	vfalico@gmail.com, jiri@resnulli.us
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1870 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757381AbaEPStB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 14:49:01 -0400
In-Reply-To: <1400261568.7973.225.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/2014 01:32 PM, Eric Dumazet wrote:
> On Fri, 2014-05-16 at 13:18 -0400, Vlad Yasevich wrote:
>> Multiple devices in the kernel can be stacked/nested and they
>> need to know their nesting level for the purposes of lockdep.
>> This patch provides a generic function that determines a nesting
>> level of a particular device by its type (ex: vlan, macvlan, etc).
>> We only care about nesting of the same type of devices.
>>
>> For example:
>>   eth0 <- vlan0.10 <- macvlan0 <- vlan1.20
>>
>> The nesting level of vlan1.20 would be 1, since there is another vlan
>> in the stack under it.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>  include/linux/netdevice.h | 10 ++++++++++
>>  net/core/dev.c            | 48 +++++++++++++++++++++++++++++++++++++++++++++++
>>  2 files changed, 58 insertions(+)
> 
> Nice, but if LOCKDEP is not used, do we really want to have
> dev_get_nest_level() being something else than a constant ?
> 
> 

Doesn't seem to hurt.  As it stands right now, vlan code will
keep calculating its own every time it needs to take a lock
and it will be other then 1 when you have a stack of them.

-vlad
