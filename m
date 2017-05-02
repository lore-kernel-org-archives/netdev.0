From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: net/smc and the RDMA core
Date: Tue, 2 May 2017 14:41:03 +0200
Message-ID: <dec979a3-a708-a814-ee99-777953fa4a4f@linux.vnet.ibm.com>
References: <20170501163311.GA22209@lst.de>
 <1493659776.2665.7.camel@sandisk.com>
 <HE1PR0502MB30048AFD086C4B0D535BFC52D1140@HE1PR0502MB3004.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <HE1PR0502MB30048AFD086C4B0D535BFC52D1140-692Kmc8YnlL9PhveBwpv4cDSnupUy6xnnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 05/01/2017 07:55 PM, Parav Pandit wrote:
> Hi Bart, Ursula, Dave,
> 
> I am particularly concerned about SMC as address family.
> It should not be treated as address family, but rather an additional protocol similar for socket type SOCK_STREAM.

We tried to avoid changes of the kernel TCP code. A new address family
seemed to be a feasible way to achieve this.

> While doing performance benchmarking last month and while porting few database application,
> 
> I encountered a major hurdle where user space library heavily depend on AF_INET and AF_INET6 family through get_addrinfo and other friend functions.
> Adding or treating AF_SMC as AF_INET just doesn't sound right.
> 
> Most user space code doesn't care for the protocol field, but do handle domain field.
> 
> I personally believe it's not too late to modify SMC to drop expose AF_SMC and have it exposed through new protocol that can be exposed through socket() API.
> 
> Parav
> 
>> -----Original Message-----
>> From: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org [mailto:linux-rdma-
>> owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of Bart Van Assche
>> Sent: Monday, May 1, 2017 12:30 PM
>> To: hch-jcswGhMUV9g@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Subject: Re: net/smc and the RDMA core
>>
>> On Mon, 2017-05-01 at 18:33 +0200, Christoph Hellwig wrote:
>>> Hi Ursual, hi netdev reviewers,
>>>
>>> how did the smc protocol manage to get merged without any review on
>>> linux-rdma at all?  As the results it seems it's very substandard in
>>> terms of RDMA API usage, e.g. it neither uses the proper CQ API nor
>>> the RDMA R/W API, and other will probably find additional issues as
>>> well.
>>
>> Hello Dave and Ursula,
>>
>> It seems very rude to me to have merged the SMC protocol driver without
>> having involved the linux-rdma community. Anyway, I have the following
>> questions for Dave and Ursula:
>> * Since the Linux kernel is standards based: where can we find the standard
>>   that defines the SMC wire protocol? If this protocol has not been
>>   standardized yet: in what file (other than *.[ch]) in the Linux kernel
>>   tree has this protocol been documented?
>> * What are the differences between the SMC protocol, the SDP protocol and
>>   the rsockets protocol? How do existing implementations for these protocols
>>   compare to each other from a performance point of view? If no performance
>>   comparison between these protocols is available, shouldn't the performance
>>   of these protocols have been compared with each other before a review of
>>   the SMC driver even started?
>> * What are the reasons why the SDP driver was never accepted upstream? Do
>>   the arguments why SDP was not accepted upstream also apply to the SMC
>>   driver (SDP = Sockets Direct Protocol)?
>> * Since SMC has to be selected by specifying AF_SMC, how are users expected
>>   to specify whether AF_INET, AF_INET6 or yet another address family should
>>   be used to set up a connection between SMC endpoints?
>> * Is the SMC driver limited to RoCE? Are you aware that the rsockets library
>>   supports multiple transport layers (RoCE, IB and iWARP)?
>> * Since functionality that is similar what the SMC driver provides already
>>   exists in user space (rsockets), why has this functionality been
>>   reimplemented as a kernel driver (SMC)?
>>
>> Bart.--
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in the body
>> of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org More majordomo info at
>> http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
