From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in netdevice
Date: Wed, 18 May 2011 13:10:50 +0200
Message-ID: <BANLkTimc1RbC3uQsra1HUvS_Trg63iMWGA@mail.gmail.com>
References: <1305574128.3456.23.camel@localhost.localdomain>
 <1305574518.2885.25.camel@bwh-desktop> <1305574680.3456.33.camel@localhost.localdomain>
 <1305575253.2885.28.camel@bwh-desktop> <20110516211459.GE18148@redhat.com>
 <1305588738.3456.65.camel@localhost.localdomain> <BANLkTimvOK3tyo6+L5AD=so5DjiDPV-AAA@mail.gmail.com>
 <1305671318.10756.49.camel@localhost.localdomain> <20110518103819.GL7589@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110518103819.GL7589@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/5/18 Michael S. Tsirkin <mst@redhat.com>:
> On Tue, May 17, 2011 at 03:28:38PM -0700, Shirley Ma wrote:
>> On Tue, 2011-05-17 at 23:48 +0200, Micha=B3 Miros=B3aw wrote:
>> > 2011/5/17 Shirley Ma <mashirle@us.ibm.com>:
>> > > Hello Michael,
>> > >
>> > > Looks like to use a new flag requires more time/work. I am think=
ing
>> > > whether we can just use HIGHDMA flag to enable zero-copy in macv=
tap
>> > to
>> > > avoid the new flag for now since mavctap uses real NICs as lower
>> > device?
>> >
>> > Is there any other restriction besides requiring driver to not rec=
ycle
>> > the skb? Are there any drivers that recycle TX skbs?
>
> Not just recycling skbs, keeping reference to any of the pages in the
> skb. Another requirement is to invoke the callback
> in a timely fashion. =A0For example virtio-net doesn't limit the time=
 until
> that happens (skbs are only freed when some other packet is
> transmitted), so we need to avoid zcopy for such (nested-virt)
> scenarious, right?

Hmm. But every hardware driver supporting SG will keep reference to
the pages until the packet is sent (or DMA'd to the device). This can
take a long time if hardware queue happens to stall for some reason.

Is it that you mean keeping a reference after all skbs pointing to the
pages are released?

>> Not more other restrictions, skb clone is OK. pskb_expand_head() loo=
ks
>> OK to me from code review.
> Hmm. pskb_expand_head calls skb_release_data while keeping
> references to pages. How is that ok? What do I miss?

It's making copy of the skb_shinfo earlier, so the pages refcount
stays the same.

Best Regards,
Micha=B3 Miros=B3aw
