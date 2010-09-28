From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v11 13/17] Add mp(mediate passthru) device.
Date: Tue, 28 Sep 2010 16:39:59 +0200
Message-ID: <201009281639.59417.arnd@arndb.de>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com> <1285622613.2263.550.camel@achroite.uk.solarflarecom.com> <20100928130654.GD14385@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, xiaohui.xin@intel.com,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com,
	Sridhar Samudrala <sri@us.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100928130654.GD14385@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 28 September 2010, Michael S. Tsirkin wrote:
> > > +   skb_reserve(skb, NET_IP_ALIGN);
> > > +   skb_put(skb, len);
> > > +
> > > +   if (skb_copy_datagram_from_iovec(skb, 0, iov, 0, len)) {
> > > +           kfree_skb(skb);
> > > +           return -EAGAIN;
> > > +   }
> > > +
> > > +   skb->protocol = eth_type_trans(skb, mp->dev);
> > 
> > Why are you calling eth_type_trans() on transmit?
> 
> So that GSO can work.  BTW macvtap does:
> 
>         skb_set_network_header(skb, ETH_HLEN);
>         skb_reset_mac_header(skb);
>         skb->protocol = eth_hdr(skb)->h_proto;
> 
> and I think this is broken for vlans. Arnd?

Hmm, that code (besides set_network_header) was added by Sridhar
for GSO support. I believe I originally did eth_type_trans but
had to change it before that time because it broke something.
Unfortunately, my memory on that is not very good any more.

Can you be more specific what the problem is? Do you think
it breaks when a guest sends VLAN tagged frames or when macvtap
is connected to a VLAN interface that adds another tag (or
only the combination)?

	Arnd
