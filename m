From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Mon, 9 Apr 2012 16:29:20 +0800
Message-ID: <20120409082919.GA3471@gondor.apana.org.au>
References: <20120408171323.GA16012@redhat.com> <20120408234951.GA15993@gondor.apana.org.au> <20120409072849.GA12014@redhat.com> <20120409073354.GA3218@gondor.apana.org.au> <20120409073953.GD12014@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jason Wang <jasowang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120409073953.GD12014@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 09, 2012 at 10:39:54AM +0300, Michael S. Tsirkin wrote:
> On Mon, Apr 09, 2012 at 03:33:54PM +0800, Herbert Xu wrote:
> > On Mon, Apr 09, 2012 at 10:28:49AM +0300, Michael S. Tsirkin wrote:
> > >
> > > > 1) Doesn't this break local UDP push-back?
> > > 
> > > What is meant by UDP pushback here? Two tap
> > > devices communicating by UDP packets locally?
> > > This was always broken, see below.
> > 
> > I mean push-back from UDP transmission to the physical NIC.
> > 
> > Your patch breaks that
> 
> I think there's some misunderstanding. pushback is only disabled
> for destinations that set IFF_TX_CAN_STALL. I expect that
> no physical NICs set this flag - only tun and possibly
> other userspace-controlled devices in the future.

I'm talking about an app running in the guest transmitting UDP
to the physical NIC via virtio/vhost.  This will break with your
patch.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
