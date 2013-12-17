From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] xen-netback: fix fragments error handling in
 checksum_setup_ip()
Date: Tue, 17 Dec 2013 16:18:00 -0500 (EST)
Message-ID: <20131217.161800.519560056108578617.davem@davemloft.net>
References: <CAPgLHd97T5bVtCEubkNqChBjSoA5V4Cka=ZQUn=JoYjPCuVE6A@mail.gmail.com>
	<9AAE0902D5BC7E449B7C8E4E778ABCD01B4F4C@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, Ian.Campbell@citrix.com, wei.liu2@citrix.com,
	zoltan.kiss@citrix.com, yongjun_wei@trendmicro.com.cn,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: Paul.Durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112Ab3LQVSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:18:02 -0500
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD01B4F4C@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <Paul.Durrant@citrix.com>
Date: Mon, 16 Dec 2013 09:40:37 +0000

>> -----Original Message-----
>> From: Wei Yongjun [mailto:weiyj.lk@gmail.com]
>> Sent: 16 December 2013 02:45
>> To: Ian Campbell; Wei Liu; Paul Durrant; Zoltan Kiss; davem@davemloft.net
>> Cc: yongjun_wei@trendmicro.com.cn; xen-devel@lists.xenproject.org;
>> netdev@vger.kernel.org
>> Subject: [PATCH -next] xen-netback: fix fragments error handling in
>> checksum_setup_ip()
>> 
>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>> 
>> Fix to return -EPROTO error if fragments detected in checksum_setup_ip().
>> 
>> Fixes: 1431fb31ecba ('xen-netback: fix fragment detection in checksum
>> setup')
>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>> ---
>>  drivers/net/xen-netback/netback.c | 3 +++
>>  1 file changed, 3 insertions(+)
>> 
>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-
>> netback/netback.c
>> index 800496b..773b731 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -1099,6 +1099,9 @@ static int checksum_setup_ip(struct xenvif *vif,
>> struct sk_buff *skb,
>> 
>>  	err = -EPROTO;
>> 
>> +	if (fragment)
>> +		goto out;
>> +
> 
> Good grief. This hunk must have got lost from my original patch. My old tree has it there. So...
> 
> Reviewed-by: Paul Durrant <paul.durrant@citrix.com>

Why is this targetted at -next?  The guilty commit this is fixing is present
in Linus's tree.

I'm going to apply it to 'net', but please take the time to specify
the correct destination tree in the future.

Thanks.
