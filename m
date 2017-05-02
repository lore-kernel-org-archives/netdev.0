From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: net/smc and the RDMA core
Date: Tue, 2 May 2017 14:34:17 +0200
Message-ID: <dce14470-06f4-8da3-6894-cd724eac3447@linux.vnet.ibm.com>
References: <20170501163311.GA22209@lst.de>
 <1493659776.2665.7.camel@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1493659776.2665.7.camel-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/01/2017 07:29 PM, Bart Van Assche wrote:
> On Mon, 2017-05-01 at 18:33 +0200, Christoph Hellwig wrote:
>> Hi Ursual, hi netdev reviewers,
>>
>> how did the smc protocol manage to get merged without any review 
>> on linux-rdma at all?  As the results it seems it's very substandard
>> in terms of RDMA API usage, e.g. it neither uses the proper CQ API
>> nor the RDMA R/W API, and other will probably find additional issues
>> as well.
> 
> Hello Dave and Ursula,
> 
> It seems very rude to me to have merged the SMC protocol driver without
> having involved the linux-rdma community. Anyway, I have the following
> questions for Dave and Ursula:
> * Since the Linux kernel is standards based: where can we find the standard
>   that defines the SMC wire protocol? If this protocol has not been
>   standardized yet: in what file (other than *.[ch]) in the Linux kernel
>   tree has this protocol been documented?

Hello Bart,

The protocol is standardized, see: http://www.rfc-editor.org/info/rfc7609.
I described this and some more protocol details in my patch series
overview mail, see for instance:
     http://marc.info/?l=linux-s390&m=148397751211964&w=2

This description explains the reasons to come up with SMC-R.

> * What are the differences between the SMC protocol, the SDP protocol and
>   the rsockets protocol? How do existing implementations for these protocols
>   compare to each other from a performance point of view? If no performance
>   comparison between these protocols is available, shouldn't the performance
>   of these protocols have been compared with each other before a review of
>   the SMC driver even started?
> * What are the reasons why the SDP driver was never accepted upstream? Do
>   the arguments why SDP was not accepted upstream also apply to the SMC
>   driver (SDP = Sockets Direct Protocol)?
> * Since SMC has to be selected by specifying AF_SMC, how are users expected
>   to specify whether AF_INET, AF_INET6 or yet another address family should
>   be used to set up a connection between SMC
> endpoints?

The IPv6 support in SMC-R is on our todo-list.

> * Is the SMC driver limited to RoCE? Are you aware that the rsockets library
>   supports multiple transport layers (RoCE, IB and iWARP)?

For now, only RoCE is supported. Other transports might be added in the future.

> * Since functionality that is similar what the SMC driver provides already
>   exists in user space (rsockets), why has this functionality been
>   reimplemented as a kernel driver (SMC)?
> 
> Bart.
> 

Regards, Ursula

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
