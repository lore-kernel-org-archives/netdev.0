From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH V5 7/9] Drivers: hv: vmbus: add a mechanism to pass hvsock
 events to the hvsock driver
Date: Tue, 5 Jan 2016 16:04:36 +0000
Message-ID: <2c7b181ef9a44ef0ac11c81ccc23ee5d@HKXPR3004MB0088.064d.mgd.msft.net>
References: <1450966491-13276-1-git-send-email-decui@microsoft.com>
 <87io3819dj.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "stephen@networkplumber.org" <stephen@networkplumber.org>,
 "stefanha@redhat.com" <stefanha@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87io3819dj.fsf@vitty.brq.redhat.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> > diff --git a/drivers/hv/channel_mgmt.c b/drivers/hv/channel_mgmt.c
> >
> > +/* hvsock related definitions */
> > +enum hvsock_event {
> > +	/* The host application is close()-ing the connection */
> > +	HVSOCK_RESCIND_CHANNEL,
> > +};
> > +
> >  struct vmbus_channel {
> >  	/* Unique channel id */
> >  	int id;
> > @@ -740,6 +746,13 @@ struct vmbus_channel {
> >  	void (*sc_creation_callback)(struct vmbus_channel *new_sc);
> >
> >  	/*
> > +	 * hvsock event callback.
> > +	 * For now only 1 event is defined: HVSOCK_RESCIND_CHANNEL.
> > +	 */
> > +	void (*hvsock_event_callback)(struct vmbus_channel *channel,
> > +				      enum hvsock_event event);
> 
> Would it make sense to rename it to something more general,
> e.g. sc_rescind_callback and call it for all drivers (even if we don't
> need it now) intead of introducing enum hvsock_event? When new events
Your suggestion is good: channel->hvsock_event_callback != NULL implies
is_hvsock_channel(channel) is true.

> arrive we'll just add new callbacks (or, alternatively, we could unify
> it to 'channel_event_callback' and merging with sc_creation_callback()
> but I'd say it is uglier).

I'm OK to use the idea "when new events arrive we'll just add new callbacks".

Let me make a new patch.

Thanks,
-- Dexuan
