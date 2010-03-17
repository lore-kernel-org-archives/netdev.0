From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] tun: add ioctl to modify vnet header size
Date: Thu, 18 Mar 2010 00:11:17 +0200
Message-ID: <20100317221117.GA7541@redhat.com>
References: <20100317213504.GA7433@redhat.com> <OFB24B6EEE.B788B01F-ON882576E9.00789167-882576E9.0079198A@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	David Woodhouse <David.Woodhouse@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Paul Moore <paul.moore@hp.com>,
	sri@linux.vnet.ibm.com
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OFB24B6EEE.B788B01F-ON882576E9.00789167-882576E9.0079198A@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 17, 2010 at 03:02:44PM -0700, David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 03/17/2010 02:35:04 PM:
> 
> > On Wed, Mar 17, 2010 at 02:10:11PM -0700, David Stevens wrote:
> > > Shouldn't we enforce a maximum too? Esp. if overflow/underflow
> > > will break any of the checks when it's used.
> > > 
> > >                                 +-DLS
> > 
> > So the maximum is MAX_INT :)
> > I don't think it can break any checks that aren't
> > already broken - what do you have in mind?
> 
>         I was thinking more like a page. At least, it'd be better
> to fail when trying to set it large than failing allocations
> later. As a header, it really ought to be small.
>         But if it works, or fails gracefully, at 2^31-1 on 32-bit
> machines, negative values, etc, then it's ok. Just a suggestion.
> 
>                                                         +-DLS

All this does is set how much of the buffer to skip, this option does
not allocate any memory.  So if you set it to a value > length that you
passed in, you get -EINVAL. Anything else should work.  Negative values
are checked for and return -EINVAL when you try to set it.  At least,
all that's by design - pls take a look at the code and if you see any
issues, speak up please.

I agree we don't really need to support very large values here,
it just seemed less work.

-- 
MST
