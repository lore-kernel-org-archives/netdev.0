From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] vxlan: remove vxlan_group_used in vxlan_open
Date: Tue, 10 Dec 2013 14:26:30 +0800
Message-ID: <52A6B416.7@cn.fujitsu.com>
References: <1386234096-18441-1-git-send-email-gaofeng@cn.fujitsu.com> <20131209.193244.2227545675987687506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:28443 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750764Ab3LJGZX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 01:25:23 -0500
In-Reply-To: <20131209.193244.2227545675987687506.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2013 08:32 AM, David Miller wrote:
> From: Gao feng <gaofeng@cn.fujitsu.com>
> Date: Thu, 5 Dec 2013 17:01:35 +0800
> 
>> In vxlan_open, vxlan_group_used always returns true,
>> because the state of the vxlan deivces which we want
>> to open has alreay been running. and it has already
>> in vxlan_list.
>>
>> Since ip_mc_join_group takes care of the reference
>> problem. we can remove vxlan_group_used here, let
>> ip_mc_join_group resolve the reference problem.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> 
> "already" is misspelled in this commit message.
> 
> Please describe what "the reference problem" actually is.
> 

There is no reference bug here. just means we needn't to take
care of the reference of ip_mc_list, vxlan_group_used has no use here.

>> @@ -1943,8 +1943,7 @@ static int vxlan_open(struct net_device *dev)
>>  	if (!vs)
>>  		return -ENOTCONN;
>>  
>> -	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip) &&
>> -	    vxlan_group_used(vn, &vxlan->default_dst.remote_ip)) {
>> +	if (vxlan_addr_multicast(&vxlan->default_dst.remote_ip)) {
> 
> This makes "vn" unused, please remove it.
> 
> The compiler even warns about this, are you watching the build
> after making changes for messages like that?

Sorry for this. I will take care of this.

Thanks!
