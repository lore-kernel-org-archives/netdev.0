From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: 04 Oct 2007 13:52:32 +0200
Message-ID: <ygf641n14hr.fsf@janus.isnogud.escape.de>
References: <20071002131006.31727.0@janus.isnogud.escape.de>
	<20071002131112.31727.5@janus.isnogud.escape.de>
	<20071002142016.GE7881@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:36061 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758700AbXJDLzx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 07:55:53 -0400
In-Reply-To: <20071002142016.GE7881@ghostprotocols.net>; from Arnaldo Carvalho de Melo on Tue, 2 Oct 2007 11:20:16 -0300
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo <acme@ghostprotocols.net> writes:

> > +#ifdef CONFIG_CAN_DEBUG_DEVICES
> > +static int debug;
> > +module_param(debug, int, S_IRUGO);
> > +#endif
> 
> Can debug be a boolean? Like its counterpart on DCCP:

debug used to a bit mask, like it still is in core.h.  You can see
this in the test

        debug & 1 ? ... : ...

below.  Only the test for bit 0 is left, so we could change it to bool.

> net/dccp/proto.c:
> 
> module_param(dccp_debug, bool, 0444);
> 
> Where we also use a namespace prefix, for those of us who use ctags or
> cscope.

I think ctags should be able to handle multiple identical static
symbols.  Isn't it?  I find it somewhat clumsy to write

        modprobe vcan vcan_debug=1

I think it would be nice to change the module_param() macro so that
you can name the module argument and the corresponding variable
independently, like

        module_param(can_debug, "debug", bool, 0444);

OK, forget that last paragraph.  I've looked at the definition of
module_param() and have seen that we have module_param_named().  I
think we should use that.

> > +
> > +/* To be moved to linux/can/dev.h */
> 
> Is this comment still valid? If so can this move happen now? If not I
> think it would be better to stick a "FIXME: " just before it, no?

OK.

> > +static int echo; /* echo testing. Default: 0 (Off) */
> > +module_param(echo, int, S_IRUGO);
> > +MODULE_PARM_DESC(echo, "Echo sent frames (for testing). Default: 0 (Off)");
> 
> echo also seems to be a boolean

ACK.

> > +static int vcan_open(struct net_device *dev)
> > +{
> > +	DBG("%s: interface up\n", dev->name);
> > +
> > +	netif_start_queue(dev);
> > +	return 0;
> > +}
> > +
> > +static int vcan_stop(struct net_device *dev)
> > +{
> > +	DBG("%s: interface down\n", dev->name);
> > +
> > +	netif_stop_queue(dev);
> > +	return 0;
> > +}
> 
> Thinking out loud: I guess these days we can try to reduce the clutter
> on the source code for things like "hey, I entered function foo" using
> simple systemtap scripts, that could even be shipped with the kernel
> sources. Not something pressing right now, just a suggestion.

I've never heard of systemtap before.  I've ust looked at its overview
web page which sounds promising.  I think I'll check it out when time
permits...


urs
