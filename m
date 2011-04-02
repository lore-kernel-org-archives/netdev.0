From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH] net: ethtool support to configure number of channels
Date: Sat, 02 Apr 2011 03:55:46 +0100
Message-ID: <1301712946.10056.179.camel@localhost>
References: <1301652075-382-1-git-send-email-amit.salecha@qlogic.com>
	 <1301677824.4679.10.camel@bwh-desktop>
	 <99737F4847ED0A48AECC9F4A1974A4B80FD10E8D93@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:41055 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756065Ab1DBCzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:55:51 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80FD10E8D93@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-01 at 21:36 -0500, Amit Salecha wrote:
> > I'm not sure why you reduced this to a single count.  If if the driver
> > or hardware doesn't allow certain combinations of counts, it might be
> > necessary to configure several types at the same time
> >
> > > +/* Channel ID is made up of a type */
> > > +enum ethtool_channel_id {
> > > +   ETH_CHAN_TYPE_RX = 0x1,
> > > +   ETH_CHAN_TYPE_TX = 0x2
> > > +};
> > [...]
> >
> > enum ethtool_channel_id was meant to be an identifier of a specific
> > channel.  An enumeration of channel types should be named differently.
> >
> 
> I will name it as ethtool_channel_type. Any other suggestion ?
> 
> > This also omits the 'combined' and 'other' types.  Most multiqueue
> > drivers pair up RX and TX queues so that most channels combine RX and
> > TX
> > work.
> 
> 'combined' is ok, what is use of 'other' ?

Could be link interrupts, SR-IOV coordination, or something else.  Not
something you'd likely be able to change, but it could be useful to know
that some interrupts are allocated to them.  Actually, that does mean it
might be helpful for the 'get' operation to return a minimum value along
with the maximum value.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

