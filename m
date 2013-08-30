From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 3/5] bonding: add rtnl lock for bonding_store_xmit_hash
Date: Fri, 30 Aug 2013 11:26:38 +0800
Message-ID: <522010EE.20506@huawei.com>
References: <521D7ABE.5080700@huawei.com> <521F59E6.9050804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:61230 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298Ab3H3D1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:27:00 -0400
In-Reply-To: <521F59E6.9050804@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/29 22:25, Nikolay Aleksandrov wrote:
> On 08/28/2013 06:21 AM, Ding Tianhong wrote:
>> The bonding_store_xmit_hash() call bond_set_mode_ops() to set bond xmit_policy,
>> the xmit_policy is used in xmit path for xor mode, so any changes may occur
>> problem without protection, add rtnl lock is fit here.
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
> I don't think we need any locking there, nothing bad can happen.
> 
> 
> 
But I think bond->xmit_hash_policy need protect if write it, as the bond_3ad_xmit may use it,
or did I miss something? :) 
