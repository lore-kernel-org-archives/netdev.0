From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/6] ipv4: fix sending of redirects
Date: Mon, 08 Oct 2012 16:41:58 -0400 (EDT)
Message-ID: <20121008.164158.1437741527673072117.davem@davemloft.net>
References: <1349609168-9848-2-git-send-email-ja@ssi.bg>
	<20121008.151633.753185005887436197.davem@davemloft.net>
	<alpine.LFD.2.00.1210082259180.12172@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753163Ab2JHUmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 16:42:00 -0400
In-Reply-To: <alpine.LFD.2.00.1210082259180.12172@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Mon, 8 Oct 2012 23:43:45 +0300 (EEST)

> On Mon, 8 Oct 2012, David Miller wrote:
> 
>> From: Julian Anastasov <ja@ssi.bg>
>> Date: Sun,  7 Oct 2012 14:26:03 +0300
>> 
>> > @@ -322,7 +322,8 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
>> >  {
>> >  	int r = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
>> >  
>> > -	if (!r && !fib_num_tclassid_users(dev_net(dev))) {
>> > +	if (!r && !fib_num_tclassid_users(dev_net(dev)) &&
>> > +	    dev->ifindex != oif) {
>> >  		*itag = 0;
>> >  		return 0;
>> >  	}
>> 
>> Hmmm, won't this cause the slow path to be taken for locally
>> destined traffic?
> 
> 	In this case idev=eth0 and oif=lo. The only case
> where we can see same input and output device is for
> forwarding and loopback (but only output routes where
> there is no such validation).

Ok, now I understand.  This added condition is fine.

Thanks.
