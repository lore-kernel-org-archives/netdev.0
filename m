From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: Handle postive return codes in phy_connect
Date: Sat, 5 Sep 2015 21:47:55 +0200
Message-ID: <20150905194755.GD6040@lunn.ch>
References: <1441476089-22108-1-git-send-email-mwelling@ieee.org>
 <20150905191840.GC6040@lunn.ch>
 <20150905194400.GA1687@deathstar>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michael Welling <mwelling@ieee.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150905194400.GA1687@deathstar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 05, 2015 at 02:44:01PM -0500, Michael Welling wrote:
> On Sat, Sep 05, 2015 at 09:18:40PM +0200, Andrew Lunn wrote:
> > On Sat, Sep 05, 2015 at 01:01:29PM -0500, Michael Welling wrote:
> > > The function phy_connect_direct can possibly return a positive
> > > return code. Using ERR_PTR with a positive value can lead to
> > > deferencing of an invalid pointer.
> > 
> > Is this the correct fix? Would it not be better to find where the
> > positive return code is from and fix that?
> 
> I guess I can trace it back to find out where the positive return code
> is originating.
> 
> Is phy_connect_direct always supposed to return valid -errno?

I would look at this from a different angle. A positive ERRNO is
probably a bug of some sort. So rather than papering over the cracks,
go find what the real issue is.

It might not be an ERRNO. E.g. https://lkml.org/lkml/2015/9/3/534
fixed a bug where a positive value is returned which is not an
indication of an error.

	   Andrew
