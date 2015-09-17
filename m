From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next RFC] net: increase LL_MAX_HEADER for Hyper-V
Date: Thu, 17 Sep 2015 08:38:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB989E9@AcuExch.aculab.com>
References: <1442418625-11805-1-git-send-email-vkuznets@redhat.com>
 <BN1PR0301MB0770C47D37D272F5A28CD1DECA5B0@BN1PR0301MB0770.namprd03.prod.outlook.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB9800B@AcuExch.aculab.com>
 <BY2PR0301MB16548B482FF9E0F4D82FC2C8A05B0@BY2PR0301MB1654.namprd03.prod.outlook.com>
 <55F9E172.2040008@gmail.com>
 <BY2PR0301MB16540426BFD633C8EBD1A4BBA05B0@BY2PR0301MB1654.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jason Wang <jasowang@redhat.com>
To: 'KY Srinivasan' <kys@microsoft.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"Vitaly Kuznetsov" <vkuznets@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BY2PR0301MB16540426BFD633C8EBD1A4BBA05B0@BY2PR0301MB1654.namprd03.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: KY Srinivasan
> Sent: 16 September 2015 23:58
...
> > I think we get that.  The question is does the Remote NDIS header and
> > packet info actually need to be a part of the header data?  I would
> > argue that it probably doesn't.
> >
> > So for example in netvsc_start_xmit it looks like you are calling
> > init_page_array in order to populate a set of page buffers, but the
> > first buffer for the Remote NDIS protocol is populated as a separate
> > page and offset.  As such it doesn't seem like it necessarily needs to
> > be a part of the header data but could be maintained perhaps in a
> > separate ring buffer, or perhaps just be a separate page that you break
> > up to use for each header.
> 
> You are right; the rndis header can be built as a separate fragment and sent.
> Indeed this is what we were doing earlier - on the outgoing path we would allocate
> memory for the rndis header. My goal was to avoid this allocation on every packet being
> sent and I decided to use the headroom instead. If we can completely avoid all memory
> allocation for rndis header, it makes a significant perf difference:
...


So just preallocate the header space as a fixed buffer for each ring entry
(or tx frame).

If you allocate a fixed buffer for each ring entry you may find there are
performance gains from copying small fragments into the buffer instead
of doing whatever mapping operations are required.

	David
