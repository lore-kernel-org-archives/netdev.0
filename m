From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH 4/5] virtio_net: Add a MAC filter table
Date: Wed, 28 Jan 2009 22:17:55 -0800
Message-ID: <OF025C8F2F.2E8FFF17-ON8825754D.0020EE83-8825754D.002299DE@us.ibm.com>
References: <20090129003429.GA23582@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alex Williamson <alex.williamson@hp.com>, kvm@vger.kernel.org,
	markmc@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090129003429.GA23582@gondor.apana.org.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I haven't been following this closely, so apologies if the point's been 
made, or
if you're talking about unicast addresses here too, but just to be clear:

For multicasting, false positives are ok, false negatives are not 
(non-functional),
and if the fixed-size address filter is exceeded, _multicast_promiscuous_
(but not all unicasts, so not promiscuous mode) is the "good" thing to do.
So "best effort" still shouldn't lead to an address you previously joined 
not
being passed because a new one is added.

Also, if you can't keep all the MAC multicast addresses (ie,
the limit is memory and not look-up speed), then getting
out of multicast-promiscuous mode correctly isn't easy
since you don't know what groups you "forgot". You could
rebuild from the protocol memberships, if you know when
you've left enough groups to fit, but otherwise the MAC
multicast addresses you didn't keep of course won't work if you
leave multicast-promiscuous mode and the filter doesn't
have them.

So, if you're talking about not being able to fit all
the address (vs. not wanting to search that many), then
I'd suggest either staying in MP mode until ifdown, or
making the join a hard failure at the limit in the first
place.

                                                        +-DLS

