From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [V2 1/7] Drivers: hv: vmbus: define the new offer type for
 Hyper-V socket (hvsock)
Date: Thu, 16 Jul 2015 11:18:44 +0000
Message-ID: <4eb229b0935b4a42b126325c95bf7a2d@SIXPR30MB031.064d.mgd.msft.net>
References: <1436867883-17692-1-git-send-email-decui@microsoft.com>
 <20150715.211306.576715827080894506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	KY Srinivasan <kys@microsoft.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150715.211306.576715827080894506.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: David Miller
> Sent: Thursday, July 16, 2015 12:13
> 
> From: Dexuan Cui
> Date: Tue, 14 Jul 2015 02:58:03 -0700
> 
> > A helper function is also added.
> >
> > diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
> > @@ -236,6 +236,7 @@ struct vmbus_channel_offer {
> >  #define VMBUS_CHANNEL_LOOPBACK_OFFER			0x100
> >  #define VMBUS_CHANNEL_PARENT_OFFER			0x200
> >  #define VMBUS_CHANNEL_REQUEST_MONITORED_NOTIFICATION	0x400
> > +#define VMBUS_CHANNEL_TLNPI_PROVIDER_OFFER		0x2000
> >
> >  struct vmpacket_descriptor {
> >  	u16 type;
> > @@ -758,6 +759,12 @@ struct vmbus_channel {
> >  	struct list_head percpu_list;
> >  };
> >
> > +static inline bool is_hvsock_channel(const struct vmbus_channel *c)
> > +{
> > +	return !!(c->offermsg.offer.chn_flags &
> > +		VMBUS_CHANNEL_TLNPI_PROVIDER_OFFER);
> > +}
> > +
> 
> This is not indented properly, plus it makes no sense to add a flag before
> anyone even sets the flag.

Hi David,
Thanks for pointing out the indentation issue!  I'll fix it in V3.

The flag is set by the host: the c->offermsg is in the shared VMBus ringbuffer
between the host and the guest, so it makes sense for us to check the flag. :-)

-- Dexuan
