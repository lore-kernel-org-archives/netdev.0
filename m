From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Wed, 15 Sep 2010 07:27:24 +0200
Message-ID: <20100915052724.GA25481@redhat.com>
References: <1284410580.13351.10.camel@localhost.localdomain>
 <1284410883.13351.14.camel@localhost.localdomain>
 <20100913.201730.27805132.davem@davemloft.net>
 <4C8F3C77.7010302@redhat.com>
 <1284476719.13351.35.camel@localhost.localdomain>
 <F2E9EB7348B8264F86B6AB8151CE2D792B8C8152A0@shsmsx502.ccr.corp.intel.com>
 <1284518452.13351.111.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Xin, Xiaohui" <xiaohui.xin@intel.com>,
	Avi Kivity <avi@redhat.com>,
	David Miller <davem@davemloft.net>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1284518452.13351.111.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 14, 2010 at 07:40:52PM -0700, Shirley Ma wrote:
> On Wed, 2010-09-15 at 09:50 +0800, Xin, Xiaohui wrote:
> > I think what David said is what we have thought before in mp device.
> > Since we are not sure the exact time the tx buffer was wrote though
> > DMA operation.
> > But the deadline is when the tx buffer was freed. So we only notify
> > the vhost stuff
> > about the write when tx buffer freed. But the deadline is maybe too
> > late for performance.
> 
> Have you tried it? If so what's the performance penalty you have seen by
> notifying vhost when tx buffer freed?
> 
> I am thinking to have a callback in skb destructor,
> vhost_add_used_and_signal gets updated when skb is actually freed, vhost
> vq & head need to be passed to the callback. This might requires vhost
> ring size is at least as big as the lower device driver. 
> 
> Thanks
> Shirley

For some of the issues, try following the discussion around
net: af_packet: don't call tpacket_destruct_skb() until the skb is sent
out.

Summary: it's difficult to do correctly generally. Limiting ourselves
to transmit on specific devices might make it possible.

-- 
MST
