From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next RFC] net: increase LL_MAX_HEADER for Hyper-V
Date: Thu, 17 Sep 2015 21:16:24 +0000
Message-ID: <BY2PR0301MB16543959FB2FF3D1156D04C8A05A0@BY2PR0301MB1654.namprd03.prod.outlook.com>
References: <BY2PR0301MB16547020327B59C72692E730A05A0@BY2PR0301MB1654.namprd03.prod.outlook.com>
	<20150917.115218.655587837796826886.davem@davemloft.net>
	<BY2PR0301MB1654790C65E4E7EC98A76946A05A0@BY2PR0301MB1654.namprd03.prod.outlook.com>
 <20150917.131037.2286760949122849895.davem@davemloft.net>
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
In-Reply-To: <20150917.131037.2286760949122849895.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, September 17, 2015 1:11 PM
> To: KY Srinivasan <kys@microsoft.com>
> Cc: David.Laight@ACULAB.COM; alexander.duyck@gmail.com; Haiyang Zhang
> <haiyangz@microsoft.com>; vkuznets@redhat.com; netdev@vger.kernel.org;
> linux-kernel@vger.kernel.org; jasowang@redhat.com
> Subject: Re: [PATCH net-next RFC] net: increase LL_MAX_HEADER for Hyper-V
> 
> From: KY Srinivasan <kys@microsoft.com>
> Date: Thu, 17 Sep 2015 19:52:01 +0000
> 
> >
> >
> >> -----Original Message-----
> >> Have a pre-cooked ring of buffers for these descriptors that you can
> >> point the chip at.  No per-packet allocation is necessary at all.
> >
> > Even if I had a ring of buffers, I would still need to manage the life cycle
> > of these buffers - selecting an unused one on the transmit path and marking
> > it used (atomically).
> 
> Have one per TX ring entry, then the lifetime matches the lifetime of the
> TX entry itself and therefore you need do nothing.

Yes, I understand. Unfortunately, the ring buffer used on Hyper-V to send the packets to the host is not
managed as a traditional TX ring entries - it is not fixed size and a given packet can wrap around and lastly, I think
the management of space on the ring buffer is not tied to the act of completing the send operation. That is why
we have an explicit "send complete" message.

I am working on moving the model to more closely match the hardware model but it will take some time.
For now, I will implement a very light weight mechanism for managing the additional memory needed.

Regards,

K. Y
> 
> That's the whole idea.
