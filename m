From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC VLAN 10/10]: Use rtnl_link API
Date: Tue, 05 Jun 2007 23:58:46 +0200
Message-ID: <4665DC96.8020100@trash.net>
References: <20070605143650.23717.91261.sendpatchset@localhost.localdomain> <20070605143703.23717.96479.sendpatchset@localhost.localdomain> <4665D64F.4040601@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38633 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755380AbXFEV64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 17:58:56 -0400
In-Reply-To: <4665D64F.4040601@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Patrick McHardy wrote:
> 
>> [VLAN]: Use rtnl_link API
>>
>> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> 
>> +static int vlan_newlink(struct net_device *dev,
>> +            struct nlattr *tb[], struct nlattr *data[])
>> +{
>> +    struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
>> +    int err;
>> +
>> +    if (!tb[IFLA_LINK])
>> +        return -EINVAL;
>> +    if (!data[IFLA_VLAN_ID])
>> +        return -EINVAL;
>> +
>> +    vlan->vlan_id  = nla_get_u16(data[IFLA_VLAN_ID]);
>> +    vlan->real_dev = __dev_get_by_index(nla_get_u32(tb[IFLA_LINK]));
> 
> 
> It seems you are scribbling on dev->priv before you validate that
> it is OK to do so?
> 
> Or, maybe I'm just confused.
> 
> What is 'dev' here?


Its a newly created device, not registered at this point. The
vlan_dev_info structure is used to communicate the settings
to vlan_dev_init() (also by the ioctl wrapper).

> Other than this, this patch and the others in this series
> look fine (except for the 4095 VID issue that we communicated
> about earlier).


Thanks, I'll fix that, add the remaining bits, and repost.
I think its only REORDER_HDR support that is still missing.

