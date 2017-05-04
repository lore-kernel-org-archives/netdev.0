From: "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>
Subject: Re: net/smc and the RDMA core
Date: Thu, 4 May 2017 10:48:25 +0200
Message-ID: <20170504084825.GA5399@lst.de>
References: <20170501163311.GA22209@lst.de> <d9214af6-1c6f-9f95-fc00-3e4a316b4f81@linux.vnet.ibm.com> <1493750358.2552.13.camel@sandisk.com> <1b79048f-4495-3840-e7a6-d4fa5a8dfb57@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1b79048f-4495-3840-e7a6-d4fa5a8dfb57-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 04, 2017 at 11:43:50AM +0300, Sagi Grimberg wrote:
> I would also suggest that you stop exposing the DMA MR for remote
> access (at least by default) and use a proper reg_mr operations with a
> limited lifetime on a properly sized buffer.

Yes, exposing the default DMA MR is a _major_ security risk.  As soon
as SMC is enabled this will mean a remote system has full read/write
access to the local systems memory.

There іs a reason why I removed the ib_get_dma_mr function and replaced
it with the IB_PD_UNSAFE_GLOBAL_RKEY key that has _UNSAFE_ in the name
and a very long comment explaining why, and I'm really disappointed that
we got a driver merged that instead of asking on the relevant list on
why a change unexpertong a function it needed happened and instead
tried the hard way to keep a security vulnerarbility alive.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
