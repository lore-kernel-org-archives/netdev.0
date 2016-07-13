From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v16 net-next 0/1] introduce Hyper-V VM Sockets(hv_sock)
Date: Wed, 13 Jul 2016 11:38:45 +0000
Message-ID: <CO2PR03MB2182331D3CC1FBD4BD6E4FBABF310@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <CO2PR03MB2182A5A246AFF6E8FC0E2E64BF3F0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160713073048.GD27436@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Cathy Avery <cavery@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	"joe@perches.com" <joe@perches.com>,
	Rolf Neugebauer <rolf.neugebauer@docker.com>,
	"Haiyang Zhang" <haiyangz@microsoft.com>,
	Dave Scott <dave.scott@docker.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160713073048.GD27436@unicorn.suse.cz>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Michal Kubecek [mailto:mkubecek@suse.cz]
> > ......
> > However, though Hyper-V Sockets may seem conceptually similar to
> > AF_VOSCK, there are differences in the transportation layer, and IMO these
> > make the direct code reusing impractical:
> >
> > 1. In AF_VSOCK, the endpoint type is: <u32 ContextID, u32 Port>, but in
> > AF_HYPERV, the endpoint type is: <GUID VM_ID, GUID ServiceID>. Here GUID
> > is 128-bit.
> 
> OK, this could be a problem.
> 
> > 2. AF_VSOCK supports SOCK_DGRAM, while AF_HYPERV doesn't.
> >
> > 3. AF_VSOCK supports some special sock opts, like
> SO_VM_SOCKETS_BUFFER_SIZE,
> > SO_VM_SOCKETS_BUFFER_MIN/MAX_SIZE and
> SO_VM_SOCKETS_CONNECT_TIMEOUT.
> > These are meaningless to AF_HYPERV.
> >
> > 4. Some AF_VSOCK's VMCI transportation ops are meanless to
> AF_HYPERV/VMBus,
> > like .notify_recv_init
> > .notify_recv_pre_block
> > .notify_recv_pre_dequeue
> > .notify_recv_post_dequeue
> > .notify_send_init
> > .notify_send_pre_block
> > .notify_send_pre_enqueue
> > .notify_send_post_enqueue
> > etc.
> >
> > So I think we'd better introduce a new address family: AF_HYPERV.
> 
> I don't quite understand the logic here. All these sound like "AF_VSOCK
> has this feature we don't need so (rather than not using the feature) we
> are not going to use AF_VSOCK". I would understand if you pointed out
> features important for you that are missing in AF_VSOCK but this kind of
> reasoning sounds strange to me.
> 
> Michal Kubecek

Hi Michal,
Sorry, I might not have made me clear.
I didn't mean "AF_VSOCK has this feature we don't need". I didn't mean
"features important for me that are missing in AF_VSOCK", either.

I just wanted to say that I need a new protocol number and I should
have a separate directory in net/, i.e., net/hv_sock/. 

Because AF_VSOCK and AF_HYPERV are conceptually similar, some
people asked why I didn't fit my code into net/vmw_vsock/ and I wrote the
text to explain why that wasn't a good idea: the implementation details
are different and I can't directly reuse the vsock code.

Thanks,
-- Dexuan
