From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] macvtap: Allow tap features change when
 IFF_VNET_HDR is disabled.
Date: Thu, 15 Aug 2013 13:16:45 -0700 (PDT)
Message-ID: <20130815.131645.1042317207899492632.davem@davemloft.net>
References: <1376586173-4242-1-git-send-email-vyasevic@redhat.com>
	<1376586173-4242-3-git-send-email-vyasevic@redhat.com>
	<20130815173347.GA10265@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759719Ab3HOUQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 16:16:48 -0400
In-Reply-To: <20130815173347.GA10265@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 15 Aug 2013 20:33:47 +0300

> On Thu, Aug 15, 2013 at 01:02:53PM -0400, Vlad Yasevich wrote:
>> When the user turns off IFF_VNET_HDR flag, attempts to change
>> offload features via TUNSETOFFLOAD do not work.  This could cause
>> GSO packets to be delivered to the user when the user is
>> not prepared to handle them.
>> 
>> To solve, allow processing of TUNSETOFFLOAD when IFF_VNET_HDR is
>> disabled.  Also, take the setting of IFF_VNET_HDR into consideration
>> when determining the feature set to apply to incommig traffic.
>> If IFF_VNET_HDR is set, we use user-specfied feature set.  if the
>> IFF_VNET_HDR is clear, we mask off all tun-specific offload features,
>> since user can not be notified of the possbile offloads.
>> 
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>  drivers/net/macvtap.c | 30 ++++++++++++++++++++++++------
>>  1 file changed, 24 insertions(+), 6 deletions(-)
>> 
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index 8121358..df45a59 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -269,6 +269,28 @@ static void macvtap_del_queues(struct net_device *dev)
>>  		sock_put(&qlist[j]->sk);
>>  }
>>  
>> +/* Determine features to be applied to the packet as it
> 
> /*
>  * Please use comments
>  * like this
>  */

Not in the networking, we use:

	/* This
	 * style.
	 */

Your misguiding people on this issue makes it hard for me
to get people to do things properly.

Thanks.
