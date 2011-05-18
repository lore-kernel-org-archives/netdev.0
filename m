From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in netdevice
Date: Wed, 18 May 2011 13:47:33 +0200
Message-ID: <BANLkTim9RQ94MT4L0QHx-yzZT5nXdbi0aQ@mail.gmail.com>
References: <1305574128.3456.23.camel@localhost.localdomain>
 <1305574518.2885.25.camel@bwh-desktop> <1305574680.3456.33.camel@localhost.localdomain>
 <1305575253.2885.28.camel@bwh-desktop> <20110516211459.GE18148@redhat.com>
 <1305588738.3456.65.camel@localhost.localdomain> <BANLkTimvOK3tyo6+L5AD=so5DjiDPV-AAA@mail.gmail.com>
 <1305671318.10756.49.camel@localhost.localdomain> <20110518103819.GL7589@redhat.com>
 <BANLkTimc1RbC3uQsra1HUvS_Trg63iMWGA@mail.gmail.com> <20110518111734.GO7589@redhat.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110518111734.GO7589@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

W dniu 18 maja 2011 13:17 u=BFytkownik Michael S. Tsirkin
<mst@redhat.com> napisa=B3:
> On Wed, May 18, 2011 at 01:10:50PM +0200, Micha=B3 Miros=B3aw wrote:
>> 2011/5/18 Michael S. Tsirkin <mst@redhat.com>:
>> > On Tue, May 17, 2011 at 03:28:38PM -0700, Shirley Ma wrote:
>> >> On Tue, 2011-05-17 at 23:48 +0200, Micha=B3 Miros=B3aw wrote:
>> >> > 2011/5/17 Shirley Ma <mashirle@us.ibm.com>:
>> >> > > Hello Michael,
>> >> > >
>> >> > > Looks like to use a new flag requires more time/work. I am th=
inking
>> >> > > whether we can just use HIGHDMA flag to enable zero-copy in m=
acvtap
>> >> > to
>> >> > > avoid the new flag for now since mavctap uses real NICs as lo=
wer
>> >> > device?
>> >> >
>> >> > Is there any other restriction besides requiring driver to not =
recycle
>> >> > the skb? Are there any drivers that recycle TX skbs?
>> > Not just recycling skbs, keeping reference to any of the pages in =
the
>> > skb. Another requirement is to invoke the callback
>> > in a timely fashion. =A0For example virtio-net doesn't limit the t=
ime until
>> > that happens (skbs are only freed when some other packet is
>> > transmitted), so we need to avoid zcopy for such (nested-virt)
>> > scenarious, right?
>> Hmm. But every hardware driver supporting SG will keep reference to
>> the pages until the packet is sent (or DMA'd to the device). This ca=
n
>> take a long time if hardware queue happens to stall for some reason.
> That's a fundamental property of zero copy transmit.
> You can't let the application/guest reuse the memory until
> no one looks at it anymore.

One more question: is userspace (or whatever is sending those packets)
denied from modifying passed pages? I assume it is, but just want to
be sure.

Best Regards,
Micha=B3 Miros=B3aw
