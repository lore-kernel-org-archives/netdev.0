From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Tue, 9 Aug 2016 13:52:23 +0800
Message-ID: <57A96F97.6010103@huawei.com>
References: <20160808211530.GH22974@cork> <20160808212112.GI22974@cork>
 <20160808214812.GJ22974@cork> <57A93D81.4030808@huawei.com>
 <20160809030956.GL22974@cork>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>, <netdev@vger.kernel.org>
To: =?UTF-8?Q?J=c3=b6rn_Engel?= <joern@purestorage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:17505 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbcHIFzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 01:55:53 -0400
In-Reply-To: <20160809030956.GL22974@cork>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/8/9 11:09, Jörn Engel wrote:
> Hello Tianhong!
> 
> On Tue, Aug 09, 2016 at 10:18:41AM +0800, Ding Tianhong wrote:
>>
>> I don't understand your problem clearly, can you explain more about how the 00503b6f702e break tun-interfaces
>> and we will try to fix it.
> 
> Here is a trivial testcase:
> openvpn --mktun --dev tun0
> echo +tun0 > /sys/class/net/bond0/bonding/slaves
> 
> Worked fine before your patch, no longer works after your patch.  Works
> again after my patch.
> 
Hi Jorn:

I check the code and know the reason, the Tun device(or something like tun...) didn't has the ndo_set_mac_address, so will not add to bond
as a slaver device in the mode rr, I think the original logic is fine for bond enslave processing, the old kernel just avoid this problem and not
fix it, the bond need to considerate the virtual device which not support changing mac.

>> and more, dev_set_mac_address will change the salver's mac address, some nic don't support to change the mac address and
>> could not work as bond slave, so we need to check the return value, I don't think this patch has any effective improvement.
> 
> Using bonding in balance-rr mode, there doesn't seem to be a need to
> change the mac address.  I suppose you might care in other modes, but I
> don't.
> 
> Jörn
> 
> --
> Time? What's that? Time is only worth what you do with it.
> -- Theo de Raadt
> 
> 
