From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: net/smc and the RDMA core
Date: Fri, 5 May 2017 19:06:56 +0200
Message-ID: <750b09b5-f898-fe7f-1e82-1f6c06cc0f58@linux.vnet.ibm.com>
References: <20170501163311.GA22209@lst.de>
 <d9214af6-1c6f-9f95-fc00-3e4a316b4f81@linux.vnet.ibm.com>
 <1493750358.2552.13.camel@sandisk.com>
 <1b79048f-4495-3840-e7a6-d4fa5a8dfb57@grimberg.me>
 <20170504084825.GA5399@lst.de>
 <efa9bd6d-1df9-952a-7f32-c2ee6bffcae5@linux.vnet.ibm.com>
 <20170504153155.GB854@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>, Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170504153155.GB854-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 05/04/2017 05:31 PM, Jason Gunthorpe wrote:
> On Thu, May 04, 2017 at 03:08:39PM +0200, Ursula Braun wrote:
>>
>>
>> On 05/04/2017 10:48 AM, hch-jcswGhMUV9g@public.gmane.org wrote:
>>> On Thu, May 04, 2017 at 11:43:50AM +0300, Sagi Grimberg wrote:
>>>> I would also suggest that you stop exposing the DMA MR for remote
>>>> access (at least by default) and use a proper reg_mr operations with a
>>>> limited lifetime on a properly sized buffer.
>>>
>>> Yes, exposing the default DMA MR is a _major_ security risk.  As soon
>>> as SMC is enabled this will mean a remote system has full read/write
>>> access to the local systems memory.
>>>
>>> There ??s a reason why I removed the ib_get_dma_mr function and replaced
>>> it with the IB_PD_UNSAFE_GLOBAL_RKEY key that has _UNSAFE_ in the name
>>> and a very long comment explaining why, and I'm really disappointed that
>>> we got a driver merged that instead of asking on the relevant list on
>>> why a change unexpertong a function it needed happened and instead
>>> tried the hard way to keep a security vulnerarbility alive.
>>>
>> Thanks for pointing out these problems. We will address them.
> 
> So, you've created a huge security hole in the kernel, anyone who
> loads your smc module is vunerable.
> 
> What are you going to do *RIGHT NOW* to mitigate this?
> 
> Jason

We do not see that just loading the smc module causes this issue.The security
risk starts with the first connection, that actually uses smc. This is only
possible if an AF_SMC socket connection is created while the so-called
pnet-table is available and offers a mapping between the used Ethernet
interface and RoCE device. Such a mapping has to be configured by a user
(via a netlink interface) and, thus, is a conscious decision by that user.

Nevertheless, thanks for all the valuable feedback; we take this security risk
seriously and addressing it is obviously at the top of our list. We're working
on this issue right now, and will post patches as soon as possible. 
 
Ursula

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
