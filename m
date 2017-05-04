From: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Subject: Re: net/smc and the RDMA core
Date: Thu, 4 May 2017 11:43:50 +0300
Message-ID: <1b79048f-4495-3840-e7a6-d4fa5a8dfb57@grimberg.me>
References: <20170501163311.GA22209@lst.de>
 <d9214af6-1c6f-9f95-fc00-3e4a316b4f81@linux.vnet.ibm.com>
 <1493750358.2552.13.camel@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1493750358.2552.13.camel-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


>> if you can point out specific issues, we will be happy to work with you
>> to get them addressed!
>
> Hello Ursula,
>
> My list of issues that I would like to see addressed can be found below. Doug,
> Christoph and others may have additional inputs. The issues that have not yet
> been mentioned in other e-mails are:
> - The SMC driver only supports one RDMA transport type (RoCE v1) but
>   none of the other RDMA transport types (RoCE v2, IB and iWARP). New
>   RDMA drivers should support all RDMA transport types transparently.
>   The traditional approach to support multiple RDMA transport types is
>   by using the RDMA/CM to establish connections.
> - The implementation of the SMC driver only supports RoCEv1. This is
>   a very unfortunate choice because:
>   - RoCEv1 is not routable and hence is limited to a single Ethernet
>     broadcast domain.
>   - RoCEv1 packets escape a whole bunch of mechanisms that only work
>     for IP packets. Firewalls pass all RoCEv1 packets and switches
>     do not restrict RoCEv1 packets to a single VLAN. This means that
>     if the network configuration is changed after an SMC connection
>     has been set up such that IP communication between the endpoints
>     of an SMC connection is blocked that the SMC RoCEv1 packets will
>     not be blocked by the network equipment of which the configuration
>     has just been changed.
> - As already mentioned by Christoph, the SMC implementation uses RDMA
>   calls that probably will be deprecated soon (ib_create_cq()) and
>   should use the RDMA R/W API instead of building sge lists itself.

I would also suggest that you stop exposing the DMA MR for remote
access (at least by default) and use a proper reg_mr operations with a
limited lifetime on a properly sized buffer.

Also, the cq polling code looks completely wrong, you should really
use the RDMA CQ API.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
