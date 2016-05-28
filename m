From: oc <oc@yunify.com>
Subject: Re: [PATCH] vxlan: Accept user specified MTU value when create new
 vxlan link
Date: Sat, 28 May 2016 23:22:28 +0800
Message-ID: <5749B7B4.60600@yunify.com>
References: <1464317351-22316-1-git-send-email-oc@yunify.com>
 <CAM_iQpULCyju9vor74ygcv5FcqFeoq9KthRuCYfo4=tF0ieHrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-211.qiye.163.com ([123.125.50.211]:64656 "EHLO
	m50-211.qiye.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbcE1PYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 May 2016 11:24:43 -0400
In-Reply-To: <CAM_iQpULCyju9vor74ygcv5FcqFeoq9KthRuCYfo4=tF0ieHrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/05/28 00:09, Cong Wang wrote:
> On Thu, May 26, 2016 at 7:49 PM, Chen Haiquan <oc@yunify.com> wrote:
>> When create a new vxlan link, example:
>>    ip link add vtap mtu 1440 type vxlan vni 1 dev eth0
>>
>> The argument "mtu" has no effect, because it is not set to conf->mtu. The
>> default value is used in vxlan_dev_configure function.
>>
>> This problem was introduced by commit 0dfbdf4102b9 (vxlan: Factor out device
>> configuration).
>>
>> Fixes: 0dfbdf4102b9 (vxlan: Factor out device configuration)
>>
>> Signed-off-by:  Chen Haiquan <oc@yunify.com>
>> ---
>>   drivers/net/vxlan.c | 3 +++
>>   1 file changed, 3 insertions(+)
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 8ff30c3..f999db2 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -3086,6 +3086,9 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
>>          if (data[IFLA_VXLAN_REMCSUM_NOPARTIAL])
>>                  conf.flags |= VXLAN_F_REMCSUM_NOPARTIAL;
>>
>> +       if (tb[IFLA_MTU])
>> +               conf.mtu = nla_get_u32(tb[IFLA_MTU]);
>> +
> IFLA_MTU is already parsed in rtnl_create_link(),
> so just use dev->mtu here? conf.mtu = dev->mtu?
Two reasons:
1. vxlan_dev_configure function check conf->mtu to determine if it need 
to change value of dev->mtu.
The logical looks better to get conf->mtu from IFLA_MTU directly.
2. This problem is a regression. The old code check tb[IFLA_MTU]. I want 
to use the same way as the past.
