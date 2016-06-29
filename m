From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v12 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Wed, 29 Jun 2016 09:17:11 +0000
Message-ID: <CO2PR03MB218240EAE216F8FCE4F8759ABF230@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <BLUPR03MB1410A0ECB526A1CD13814D36BF2E0@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160628.053350.1891488485477523405.davem@davemloft.net>
 <CO2PR03MB2182CC1DA2804F09D8D77A70BF220@CO2PR03MB2182.namprd03.prod.outlook.com>
 <57729AF8.3050708@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"vkuznets@redhat.com" <vkuznets@redhat.com>,
	"cavery@redhat.com" <cavery@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"joe@perches.com" <joe@perches.com>
To: Rick Jones <rick.jones2@hpe.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57729AF8.3050708@hpe.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Rick Jones [mailto:rick.jones2@hpe.com]
> Sent: Tuesday, June 28, 2016 23:43
> To: Dexuan Cui <decui@microsoft.com>; David Miller <davem@davemloft.net>
> Cc: gregkh@linuxfoundation.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com; vkuznets@redhat.com;
> cavery@redhat.com; KY Srinivasan <kys@microsoft.com>; Haiyang Zhang
> <haiyangz@microsoft.com>; joe@perches.com
> Subject: Re: [PATCH v12 net-next 1/1] hv_sock: introduce Hyper-V Sockets
> 
> On 06/28/2016 02:59 AM, Dexuan Cui wrote:
> > The idea here is: IMO the syscalls sys_read()/write() shoudn't return
> > -ENOMEM, so I have to make sure the buffer allocation succeeds?
> >
> > I tried to use kmalloc with __GFP_NOFAIL, but I hit a warning in
> > in mm/page_alloc.c:
> > WARN_ON_ONCE((gfp_flags & __GFP_NOFAIL) && (order > 1));
> >
> > What error code do you think I should return?
> > EAGAIN, ERESTARTSYS, or something else?
> >
> > May I have your suggestion? Thanks!
> 
> What happens as far as errno is concerned when an application makes a
> read() call against a (say TCP) socket associated with a connection
> which has been reset? 
I suppose it is ECONNRESET (Connection reset by peer).

>  Is it limited to those errno values listed in the
> read() manpage, or does it end-up getting an errno value from those
> listed in the recv() manpage?  Or, perhaps even one not (presently)
> listed in either?
> 
> rick jones

Actually "man read/write" says "Other errors may occur, depending on the
object connected to fd".

"man send/recv" indeed lists ENOMEM.

Considering AF_HYPERV is a new socket type, ENOMEM seems OK to me
and I'm going to post a new version of the patch.

In the long run, I think we should add a new API in the VMBus driver,
allowing data copy from VMBus ringbuffer into user mode buffer directly.
This way, we can even eliminate this temporary buffer.

Thanks,
-- Dexuan
