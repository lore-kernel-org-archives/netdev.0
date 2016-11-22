From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net/phy: add trace events for mdio accesses
Date: Tue, 22 Nov 2016 16:19:32 +0100
Message-ID: <20161122151932.GI2691@lunn.ch>
References: <20161114110335.27862-1-uwe@kleine-koenig.org>
 <20161122100127.5940-1-uwe@kleine-koenig.org>
 <20161122095521.73d9c746@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Ingo Molnar <mingo@redhat.com>, netdev@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48517 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932592AbcKVPTj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 10:19:39 -0500
Content-Disposition: inline
In-Reply-To: <20161122095521.73d9c746@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 09:55:21AM -0500, Steven Rostedt wrote:
> On Tue, 22 Nov 2016 11:01:27 +0100
> Uwe Kleine-König <uwe@kleine-koenig.org> wrote:
> 
> > diff --git a/include/trace/events/mdio.h b/include/trace/events/mdio.h
> > new file mode 100644
> > index 000000000000..468e2d095d19
> > --- /dev/null
> > +++ b/include/trace/events/mdio.h
> > @@ -0,0 +1,42 @@
> > +#undef TRACE_SYSTEM
> > +#define TRACE_SYSTEM mdio
> > +
> > +#if !defined(_TRACE_MDIO_H) || defined(TRACE_HEADER_MULTI_READ)
> > +#define _TRACE_MDIO_H
> > +
> > +#include <linux/tracepoint.h>
> > +
> > +TRACE_EVENT_CONDITION(mdio_access,
> > +
> > +	TP_PROTO(struct mii_bus *bus, int read,
> > +		 unsigned addr, unsigned regnum, u16 val, int err),
> > +
> > +	TP_ARGS(bus, read, addr, regnum, val, err),
> > +
> > +	TP_CONDITION(err >= 0),
> > +
> > +	TP_STRUCT__entry(
> > +		__array(char, busid, MII_BUS_ID_SIZE)
> > +		__field(int, read)
> 
> read is just a 0 or 1. What about making it a char? That way we can
> pack this better. If I'm not mistaken, MII_BUS_ID_SIZE is (20 - 3) or
> 17. If read is just one byte, then it can fit in one of those three
> bytes, and you save 4 extra bytes (assuming addr will be 4 byte
> aligned).

addr could also be cast into a u8. There are a maximum of 32
addresses on an MDIO bus. Because of clause 45 MDIO, regnum needs to
remain a u32.

       Andrew
