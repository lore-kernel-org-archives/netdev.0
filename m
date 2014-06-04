From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] tap: Mark devices of type "tun" as IFF_DONT_BRIDGE
Date: Wed, 04 Jun 2014 15:40:18 -0400
Message-ID: <538F7622.2080104@redhat.com>
References: <1401905168-21559-1-git-send-email-vyasevic@redhat.com> <20140604115448.644073d0@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17451 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751201AbaFDTkZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 15:40:25 -0400
In-Reply-To: <20140604115448.644073d0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2014 02:54 PM, Stephen Hemminger wrote:
> On Wed,  4 Jun 2014 14:06:08 -0400
> Vlad Yasevich <vyasevic@redhat.com> wrote:
> 
>> Tun devices are layer 3 devices and do not work correctly
>> when bridged.  Mark then as IFF_DONT_BRIDGE so that people
>> trying to bridge will get an error.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>  drivers/net/tun.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index ee328ba..0161aa3 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -931,6 +931,7 @@ static void tun_net_init(struct net_device *dev)
>>  		/* Zero header length */
>>  		dev->type = ARPHRD_NONE;
>>  		dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
>> +		dev->priv_flags |= IFF_DONT_BRIDGE;
>>  		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
>>  		break;
>>  
> 
> This should not be necessary since bridge already checks for non-ethernet
> devices.
> 
> 	/* Don't allow bridging non-ethernet like devices */
> 	if ((dev->flags & IFF_LOOPBACK) ||
> 	    dev->type != ARPHRD_ETHER || dev->addr_len != ETH_ALEN ||
> 	    !is_valid_ether_addr(dev->dev_addr))
> 		return -EINVAL;
> 

You are right...  I was shown a snippet of the configure where this
worked, but I never asked which kernel version they were using...

Looks like the above code has been around since 3.2...

Thanks
-vlad
