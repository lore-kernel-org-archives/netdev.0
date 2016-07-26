From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v18 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 26 Jul 2016 07:09:41 +0000
Message-ID: <CO2PR03MB218232A5C9AE5DBD2AB0374ABF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <CO2PR03MB2182FD2D8AED7FFC7608510FBF0B0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160725.173701.1282720667210726281.davem@davemloft.net>
 <CO2PR03MB2182D011056AA151CCEF4EFFBF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160725.213822.1745865660912873332.davem@davemloft.net>
 <CO2PR03MB218254B70CBD052069CDEB4FBF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "mkubecek@suse.cz" <mkubecek@suse.cz>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"dave.scott@docker.com" <dave.scott@docker.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"joe@perches.com" <joe@perches.com>,
	"rolf.neugebauer@docker.com" <rolf.neugebauer@docker.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CO2PR03MB218254B70CBD052069CDEB4FBF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: devel [mailto:driverdev-devel-bounces@linuxdriverproject.org] On
> Behalf Of Dexuan Cui
> ...
> > From: David Miller [mailto:davem@davemloft.net]
> > ...
> > From: Dexuan Cui <decui@microsoft.com>
> > Date: Tue, 26 Jul 2016 03:09:16 +0000
> >
> > > BTW, during the past month, at least 7 other people also reviewed
> > > the patch and gave me quite a few good comments, which have
> > > been addressed.
> >
> > Correction: Several people gave coding style and simple corrections
> > to your patch.
> >
> > Very few gave any review of the _SUBSTANCE_ of your changes.
> >
> > And the one of the few who did, and suggested you build your
> > facilities using the existing S390 hypervisor socket infrastructure,
> > you brushed off _IMMEDIATELY_.
> >
> > That drives me crazy.  The one person who gave you real feedback
> > you basically didn't consider seriously at all.
>
> Hi David,
> I'm very sorry -- I guess I must have missed something here -- I don't
> remember somebody replied with S390 hypervisor socket
> infrastructure... I'm re-reading all the replies, trying to locate the
> reply and I'll find out why I didn't take it seriously. Sorry in advance.

Hi, David,
I checked all the comments I received and all my replies (at least I really
tried my best to check my Inbox) , but couldn't find the "S390 hypervisor
socket infrastructure" mail.

I googled "S390 hypervisor socket" but didn't find anything related (I think).

I'm really sorry -- could you please give a little more info about it?

If you meant https://lkml.org/lkml/2016/7/13/382, I don't think Michal
Kubecek was suggesting I build my code using the existing AF_VSOCK
code(?)  I think he was only asking me to clarify the way I used to write
the text to explain why I can't fit my code into the existing AF_VSOCK
code. BTW, AF_VSOCK is not on S390, I think.

If this is the case, I'm sorry I didn't explain the reason clearer.
My replies last year explained the reason with more info:
https://lkml.org/lkml/2015/7/7/1162
https://lkml.org/lkml/2015/7/17/67
And I thought people agreed that a new address family is justified.

Please let me excerpt the most related snippets in my old replies:

--------------------------------------
The biggest difference is the size of the endpoint (u128 vs. u32):
<u32 ContextID, u32 Port> in AF_VOSCK
vs.
<u128 GUID_VM_ID, u128 GUID_ServiceID> in AF_HYPERV.

In the AF_VSOCK code and the related transport layer (the wrapper
ops of VMware's VMCI), the size is widely used in kernel space
(and user space application). If I have to fit my code to AF_VSOCK
code, I would have to mess up the AF_VSOCK code in many places
by adding ugly code like:

IF the endpoint size is <u32, u32> THEN
        use the existing logic;
ELSE
        use the new logic;

And the user space application has to explicitly handle the
different endpoint sizes too.
--------------------------------------

Looking forward to your reply!

Thanks,
-- Dexuan
