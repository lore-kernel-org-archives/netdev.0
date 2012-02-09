From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: type bug in isdn_net_header()
Date: Thu, 09 Feb 2012 15:41:38 -0500 (EST)
Message-ID: <20120209.154138.441017381710297517.davem@davemloft.net>
References: <20120209104647.GB5540@elgon.mountain>
	<20120209113410.GB25634@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, isdn@linux-pingi.de,
	lucas.demarchi@profusion.mobi, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58521 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252Ab2BIUnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 15:43:01 -0500
In-Reply-To: <20120209113410.GB25634@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 9 Feb 2012 06:34:11 -0500

> On Thu, Feb 09, 2012 at 01:46:47PM +0300, Dan Carpenter wrote:
>> We use len to store the return value from eth_header().  eth_header()
>> can return -ETH_HLEN (-14).  We want to pass this back instead of
>> truncating it to 65522 and returning that.
>> 
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>> ---
>> WARNING: Compile tested only.  I don't have this hardware.  Please check
>> that I am on the right track.
>> 
>> diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
>> index 2339d73..802ab87 100644
>> --- a/drivers/isdn/i4l/isdn_net.c
>> +++ b/drivers/isdn/i4l/isdn_net.c
>> @@ -1901,7 +1901,7 @@ static int isdn_net_header(struct sk_buff *skb, struct net_device *dev,
>>  {
>>  	isdn_net_local *lp = netdev_priv(dev);
>>  	unsigned char *p;
>> -	ushort len = 0;
>> +	int len = 0;
>>  
>>  	switch (lp->p_encap) {
>>  		case ISDN_NET_ENCAP_ETHER:
>> 
> Looks reasonable
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks.
