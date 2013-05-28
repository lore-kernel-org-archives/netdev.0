From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 2/2] net: mv643xx_eth: proper initialization for
 Kirkwood SoCs
Date: Tue, 28 May 2013 14:02:27 -0400
Message-ID: <20130528180227.GY31290@titan.lakedaemon.net>
References: <1369253042-15082-2-git-send-email-sebastian.hesselbarth@gmail.com>
 <20130522201607.GA18823@obsidianresearch.com>
 <20130523160111.GP31290@titan.lakedaemon.net>
 <20130523171112.GB31281@obsidianresearch.com>
 <20130523172339.GQ31290@titan.lakedaemon.net>
 <20130523175357.GB2821@obsidianresearch.com>
 <20130523184028.GU31290@titan.lakedaemon.net>
 <20130523190140.GA4010@obsidianresearch.com>
 <20130524164636.GV31290@titan.lakedaemon.net>
 <20130524173306.GA30022@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
 Lennert Buytenhek <buytenh@wantstofly.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20130524173306.GA30022@obsidianresearch.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Jason,

Sorry, I meant to get back to this earlier and it slipped off of my
plate. :(

On Fri, May 24, 2013 at 11:33:06AM -0600, Jason Gunthorpe wrote:
> On Fri, May 24, 2013 at 12:46:36PM -0400, Jason Cooper wrote:
> 
> > > Why are you not keen on this? It seems like normal device driver
> > > practice, that is what the data field of of_device_id is typically
> > > used for..
> > 
> > I'm not keen on it because we don't have a document saying "All kirkwood
> > SoCs need PSC1 set to X after reset."  We know it, but have we tested
> > the 6282?
> 
> I disagree. The manul is very clear how PSC1 must be set for proper
> operation. Clk125BypassEn bit is used only for loopback testing, it
> should never set for driver operation. Similarly PortReset must be
> cleared for driver operation.
> 
> It is always safe for the driver to clear these bits, if it knows they
> are available.  In fact, I would argue the driver should always clear
> these bits so that the bootloader isn't relied on to do it. It doesn't
> matter if the SOC errantly sets the bit or not, it can *always* be
> safely cleared.

Great!

> Further, I compared my 88F6282/88F6283 manual against the public
> 88F6180/88F619x/88F6281 spec and confirmed that the PSC1 layout is the
> same.

Even better.

> So all of these SOC's can share a driver compatible string.

Ok, "marvell,kirkwood-eth" works for me then.  I think Sebastian already
has patches for that.

> AFAICT the only reason the driver doesn't touch PSC1 today is because
> the PSC1 was introduced in a later IP revision and its presence isn't
> auto-detectable.

Makes sense.

> The last bit of the puzzle to get bootloader independence on kirkwood
> is to encode the phy interface type (GMII/RGMII/BASE-X) in the DT so
> the entire PSC1 can be set by the driver..

Hmm, let's work on that separately, and later.  I've snowballed this
attempt enough ;-)

Thanks for digging into this for us,

Jason.
