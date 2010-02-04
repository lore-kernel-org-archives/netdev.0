From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2.6.33 1/4] net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Thu, 4 Feb 2010 15:38:07 -0800
Message-ID: <20100204153807.69d9037a@nehalam>
References: <14385191E87B904DBD836449AA30269D021A51@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Dave Miller" <davem@davemloft.net>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14385191E87B904DBD836449AA30269D021A51@MORGANITE.micrel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 4 Feb 2010 15:18:54 -0800
"Ha, Tristram" <Tristram.Ha@Micrel.Com> wrote:

> Dave Miller wrote:
> >> This is a resubmission of the Micrel KSZ8841/2 PCI Ethernet driver.
> >
> > The procfs stuff is a non-starter.
> >
> > There will undoubtedly be other devices that have switch-like
> > facilities that we'd like to export configuration support for.
> >
> > The last thing we want is a bunch of procfs files that each
> > driver decides the layout and behavior of.
> >
> > We need a centralized way to config such things, and probably
> > the best is to have a rtnl_link_ops facility to get at the
> > ports and configure them with attribute blobs or similar.
> >
> > We also said in your first submission that the way you're
> > getting at the bridge STP stuff with things like:
> >
> > +/* Needed for STP support. */
> > +#ifdef CONFIG_KSZ8842_STP
> > +#include <../net/bridge/br_private.h>
> > +#endif
> > Yet you left all of this stuff in there.
> 
> In my discussions with Alan Cox and Stephen Hemminger, I thought they kind of agree to the code's inclusion in the driver.  Sorry for my misunderstanding.  I will submit another one with those code removed.
> 
> P.S. I did not actually receive your response from my company's e-mail server.  I copied it from LKML.

I would rather move any defines needed by driver to
new file: include/net/bridge.h
and include it in br_private.h

Don't want device dumpster diving into bridge control structures.

-- 
