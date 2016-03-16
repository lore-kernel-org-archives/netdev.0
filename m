From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next 0/6] bridge: support sending rntl info when we
 set attributes through sysfs/ioctl
Date: Wed, 16 Mar 2016 22:59:37 +0800
Message-ID: <CADvbK_ce_0p8j4pi3wQ6OkYWVZOde6guhGKdJ49H0W228df27g@mail.gmail.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
	<56E96DFC.7090608@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:32974 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935001AbcCPO7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 10:59:37 -0400
Received: by mail-oi0-f65.google.com with SMTP id c203so2643523oia.0
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 07:59:37 -0700 (PDT)
In-Reply-To: <56E96DFC.7090608@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 10:30 PM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> On 03/16/2016 02:34 PM, Xin Long wrote:
>> This patchset is used to support sending rntl info to user in some places,
>> and ensure that whenever those attributes change internally or from sysfs,
>> that a netlink notification is sent out to listeners.
>>
>> It also make some adjustment in bridge sysfs so that we can implement this
>> easily.
>>
>> I've done some tests on this patchset, like:
>> [br_sysfs]
>>   1. change all the attribute values of br or brif:
>>   $ echo $value > /sys/class/net/br0/bridge/{*}
>>   $ echo $value > /sys/class/net/br0/brif/eth1/{*}
>>
>>   2. meanwhile, on another terminal to observe the msg:
>>   $ bridge monitor
>>
>> [br_ioctl]
>>   1. in bridge-utils package, do some changes in br_set, let brctl command
>>   use ioctl to set attribute:
>>          if ((ret = set_sysfs(path, value)) < 0) { -->
>>          if (1) {
>>
>>   $ brctl set*
>>
>>   2. meanwhile, on another terminal to observe the msg:
>>   $ bridge monitor
>>
>> This test covers all the attributes that brctl and sysfs support to set.
>>
>
> Please also include the bridge maintainers (CCed).
>
okay,  I will post v2 with CC maintainers.
thanks
