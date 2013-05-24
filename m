From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH 2/2] net: mv643xx_eth: proper initialization for Kirkwood
 SoCs
Date: Fri, 24 May 2013 11:33:06 -0600
Message-ID: <20130524173306.GA30022@obsidianresearch.com>
References: <1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369253042-15082-2-git-send-email-sebastian.hesselbarth@gmail.com>
 <20130522201607.GA18823@obsidianresearch.com>
 <20130523160111.GP31290@titan.lakedaemon.net>
 <20130523171112.GB31281@obsidianresearch.com>
 <20130523172339.GQ31290@titan.lakedaemon.net>
 <20130523175357.GB2821@obsidianresearch.com>
 <20130523184028.GU31290@titan.lakedaemon.net>
 <20130523190140.GA4010@obsidianresearch.com>
 <20130524164636.GV31290@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linux-kernel@vger.kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130524164636.GV31290@titan.lakedaemon.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 24, 2013 at 12:46:36PM -0400, Jason Cooper wrote:

> > Why are you not keen on this? It seems like normal device driver
> > practice, that is what the data field of of_device_id is typically
> > used for..
> 
> I'm not keen on it because we don't have a document saying "All kirkwood
> SoCs need PSC1 set to X after reset."  We know it, but have we tested
> the 6282?

I disagree. The manul is very clear how PSC1 must be set for proper
operation. Clk125BypassEn bit is used only for loopback testing, it
should never set for driver operation. Similarly PortReset must be
cleared for driver operation.

It is always safe for the driver to clear these bits, if it knows they
are available.  In fact, I would argue the driver should always clear
these bits so that the bootloader isn't relied on to do it. It doesn't
matter if the SOC errantly sets the bit or not, it can *always* be
safely cleared.

Further, I compared my 88F6282/88F6283 manual against the public
88F6180/88F619x/88F6281 spec and confirmed that the PSC1 layout is the
same.

So all of these SOC's can share a driver compatible string.

AFAICT the only reason the driver doesn't touch PSC1 today is because
the PSC1 was introduced in a later IP revision and its presence isn't
auto-detectable.

The last bit of the puzzle to get bootloader independence on kirkwood
is to encode the phy interface type (GMII/RGMII/BASE-X) in the DT so
the entire PSC1 can be set by the driver..

Jason
