From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next RFC] net: increase LL_MAX_HEADER for Hyper-V
Date: Thu, 17 Sep 2015 19:52:01 +0000
Message-ID: <BY2PR0301MB1654790C65E4E7EC98A76946A05A0@BY2PR0301MB1654.namprd03.prod.outlook.com>
References: <BY2PR0301MB16540426BFD633C8EBD1A4BBA05B0@BY2PR0301MB1654.namprd03.prod.outlook.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CB989E9@AcuExch.aculab.com>
	<BY2PR0301MB16547020327B59C72692E730A05A0@BY2PR0301MB1654.namprd03.prod.outlook.com>
 <20150917.115218.655587837796826886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"vkuznets@redhat.com" <vkuznets@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150917.115218.655587837796826886.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, September 17, 2015 11:52 AM
> To: KY Srinivasan <kys@microsoft.com>
> Cc: David.Laight@ACULAB.COM; alexander.duyck@gmail.com; Haiyang Zhang
> <haiyangz@microsoft.com>; vkuznets@redhat.com; netdev@vger.kernel.org;
> linux-kernel@vger.kernel.org; jasowang@redhat.com
> Subject: Re: [PATCH net-next RFC] net: increase LL_MAX_HEADER for Hyper-V
> 
> From: KY Srinivasan <kys@microsoft.com>
> Date: Thu, 17 Sep 2015 15:14:05 +0000
> 
> > I think I can achieve my original goal of not having any allocation
> > in the send path by carefully using the memory available in the skb:
> 
> Please stop flat-out ignoring David L.'s suggestion.

I am sorry; I did not mean to convey that impression.

> 
> Have a pre-cooked ring of buffers for these descriptors that you can
> point the chip at.  No per-packet allocation is necessary at all.

Even if I had a ring of buffers, I would still need to manage the life cycle
of these buffers - selecting an unused one on the transmit path and marking
it used (atomically). Once the transmit completes (as indicated by the transmit complete
callback) this buffer needs to be marked free. I can certainly make these operations
efficient and  lock-free, but they are still at some level an allocation/free
operation albeit potentially more efficient than having the kernel allocate the memory.
 
> 
> If you play games with SKBs you will get burned.

I will implement Dave L's suggestion. However, I am curious as to why you would consider
my proposed usage of the skb headroom and the control buffer area in skb as non-standard
usage.

Regards,

K. Y 


  
