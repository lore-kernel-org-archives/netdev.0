From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] bonding: remove skb_share_check in
 handle_frame
Date: Wed, 2 Mar 2011 11:03:55 +0100
Message-ID: <20110302100354.GB2858@psychotron.brq.redhat.com>
References: <20110301062250.GB2855@psychotron.redhat.com>
 <20110301092907.GG2855@psychotron.redhat.com>
 <20110301203843.GN11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16897 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756233Ab1CBKEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 05:04:00 -0500
Content-Disposition: inline
In-Reply-To: <20110301203843.GN11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 01, 2011 at 09:38:43PM CET, andy@greyhouse.net wrote:
>On Tue, Mar 01, 2011 at 10:29:07AM +0100, Jiri Pirko wrote:
>> Unapplicable, sorry (wrong branch :(). Here's corrected patch:
>> 
>> Subject: [PATCH net-next-2.6 v2] bonding: remove skb_share_check in handle_frame
>> 
>> No need to do share check here.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> ---
>>  drivers/net/bonding/bond_main.c |    3 ---
>>  1 files changed, 0 insertions(+), 3 deletions(-)
>> 
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 584f97b..367ea60 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1498,9 +1498,6 @@ static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
>>  	struct net_device *slave_dev;
>>  	struct net_device *bond_dev;
>>  
>> -	skb = skb_share_check(skb, GFP_ATOMIC);
>> -	if (unlikely(!skb))
>> -		return NULL;
>>  	slave_dev = skb->dev;
>>  	bond_dev = ACCESS_ONCE(slave_dev->master);
>>  	if (unlikely(!bond_dev))
>> -- 
>> 1.7.3.4
>> 
>
>Why did you decide to get rid of it here rather than the 3 places in the
>bonding driver where it is currently needed?  I think this can cover
>those cases since bond_handle_frame will be called after the ptype_all
>handlers before any of the ptype handlers.

I have already a patch prepared which converts bond ptype handlers into
being called from bond_handle_frame. You are propably right that this
should probably stay here.

So please Dave, drop this patch for now. Thanks.
