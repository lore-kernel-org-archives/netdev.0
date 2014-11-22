From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH 1/4] rtnetlink: new flag NLM_F_HW_OFFLOAD to indicate
 kernel object offload to hardware
Date: Fri, 21 Nov 2014 16:10:15 -0800
Message-ID: <546FD467.5030602@cumulusnetworks.com>
References: <1416610170-21224-2-git-send-email-roopa@cumulusnetworks.com> <20141121231234.GA20810@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	gospo@cumulusnetworks.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:49584 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbaKVAKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 19:10:20 -0500
In-Reply-To: <20141121231234.GA20810@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/14, 3:12 PM, Thomas Graf wrote:
> On 11/21/14 at 02:49pm, roopa@cumulusnetworks.com wrote:
>> diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
>> index 1a85940..f78522d 100644
>> --- a/include/uapi/linux/netlink.h
>> +++ b/include/uapi/linux/netlink.h
>> @@ -54,6 +54,8 @@ struct nlmsghdr {
>>   #define NLM_F_ACK		4	/* Reply with ack, with zero or error code */
>>   #define NLM_F_ECHO		8	/* Echo this request 		*/
>>   #define NLM_F_DUMP_INTR		16	/* Dump was inconsistent due to sequence change */
>> ++#define NLM_F_KERNEL       32      /* This msg is only for the kernel */
>> +#define NLM_F_HW_OFFLOAD	64	/* offload this msg to hw */
>>   
>>   /* Modifiers to GET request */
>>   #define NLM_F_ROOT	0x100	/* specify tree	root	*/
> The NLM_F_ flag space applies to all Netlink messages including non
> networking bits and is reserved for flags vital to the functioning
> of the Netlink protocol itself. I suggest you move this to a
> RTNETLINK specific flags space.

I did try to add it at a layer lower than the netlink header. But, 
nothing else fits so well as this :).
I did not find a place where i could make it a global flag for just 
networking objects. As I mention in my patch description,
If not here it will be a per subsystem flag/attribute. I can post a 
patch showing that approach as well.

Thanks!.
