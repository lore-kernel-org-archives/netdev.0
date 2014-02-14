From: Andrew Bennieston <andrew.bennieston@citrix.com>
Subject: Re: [PATCH V2 net-next 2/5] xen-netback: Add support for multiple
 queues
Date: Fri, 14 Feb 2014 15:42:54 +0000
Message-ID: <52FE397E.8050502@citrix.com>
References: <1392378624-6123-1-git-send-email-andrew.bennieston@citrix.com> <1392378624-6123-3-git-send-email-andrew.bennieston@citrix.com> <20140214141125.GB18398@zion.uk.xensource.com> <52FE2ED5.3020905@citrix.com> <20140214153620.GE18398@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:56480 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751277AbaBNPm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 10:42:56 -0500
In-Reply-To: <20140214153620.GE18398@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/02/14 15:36, Wei Liu wrote:
> On Fri, Feb 14, 2014 at 02:57:25PM +0000, Andrew Bennieston wrote:
>> On 14/02/14 14:11, Wei Liu wrote:
>>> On Fri, Feb 14, 2014 at 11:50:21AM +0000, Andrew J. Bennieston wrote:
>>> [...]
>>>>
>>>> +extern unsigned int xenvif_max_queues;
>>>> +
>>>>   #endif /* __XEN_NETBACK__COMMON_H__ */
>>>> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
>>>> index 4cde112..4dc092c 100644
>>>> --- a/drivers/net/xen-netback/interface.c
>>>> +++ b/drivers/net/xen-netback/interface.c
>>>> @@ -373,7 +373,12 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>>>>   	char name[IFNAMSIZ] = {};
>>>>
>>>>   	snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);
>>>> -	dev = alloc_netdev_mq(sizeof(struct xenvif), name, ether_setup, 1);
>>>> +	/* Allocate a netdev with the max. supported number of queues.
>>>> +	 * When the guest selects the desired number, it will be updated
>>>> +	 * via netif_set_real_num_tx_queues().
>>>> +	 */
>>>> +	dev = alloc_netdev_mq(sizeof(struct xenvif), name, ether_setup,
>>>> +						  xenvif_max_queues);
>>>
>>> Indentation.
>>
>> How would you like this to be indented? The CodingStyle says (and I quote):
>> Chapter 2: Breaking long lines and strings:
>> 	... descendants are always substantially shorter than the
>> 	parent and placed substantially to the right...
>>
>> There is no further advice to this point in CodingStyle, so please
>> explain how you'd prefer this.
>>
>
> Kernel code in general use indentation style like
>
> 	dev = alloc_netdev_mq(sizeof(struct xenvif), name, ether_setup,
> 			      xenvif_max_queues);
>
> You can find lots of examples in existing kernel code.
>
> Probably "place substantially to the right" is just too vague. :-)

Ah, I think the issue here is that my editor was configured to have a 
tab width of 4, so the offending line _did_ look to be aligned to the 
opening ( of the line above, to me. I'll set the appropriate tab width 
and change it.

Cheers,
Andrew
>
> Wei.
>
