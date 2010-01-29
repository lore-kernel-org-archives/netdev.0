From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] net: macvtap driver
Date: Fri, 29 Jan 2010 20:49:52 +0100
Message-ID: <201001292049.52308.arnd@arndb.de>
References: <201001271104.20607.arnd@arndb.de> <201001282118.09164.arnd@arndb.de> <20100129112141.GA6548@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@voltaire.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754433Ab0A2TuI@vger.kernel.org>
In-Reply-To: <20100129112141.GA6548@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 29 January 2010, Michael S. Tsirkin wrote:
> > That may well be, I haven't tried vlan. What do you think it should do
> > then?
> 
> Look at eth_type for a more complete packet parsing.

ok. I initially called that but it crashed because the skb was not initialized
properly at that point. I'll have a look.

> > > > +/*
> > > > + * provide compatibility with generic tun/tap interface
> > > > + */
> > > > +static long macvtap_ioctl(struct file *file, unsigned int cmd,
> > > > +                   unsigned long arg)
> > > > +{
> > > 
> > > All of these seem to be stubs, and tun has many more that you didn't
> > > stub out. So, why do you bother to support any ioctls at all?
> > 
> > Again, minimum features to get things going. qemu fails to open
> > the device if these ioctls are not implemented, but any of the
> > more advanced features are left out.
> 
> This is strange, could be application bug.  E.g. send buf size is
> relatively new and apps should handle failure gracefully.  IMO,
> returning success and ignoring the value is not a good idea.  How about
> we just fix qemu?  What about other apps?

Ok, I'll go through the ioctls again and make sure they behave correctly
they way you said. I haven't tried against against anything but qemu and
cat.

	Arnd
