From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next v2 1/3] net: add ndo to get id of physical port
 of the device
Date: Sun, 21 Jul 2013 16:00:02 +0100
Message-ID: <1374418802.16533.80.camel@deadeye.wl.decadent.org.uk>
References: <1374342834-10814-1-git-send-email-jiri@resnulli.us>
	 <1374342834-10814-2-git-send-email-jiri@resnulli.us>
	 <CAJZOPZJaKbMhtN4JSi6ScaRtwUNMK69trCccsdZvA7=57cDknQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <stephen@networkplumber.org>,
	<Narendra_K@dell.com>, <john.r.fastabend@intel.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30546 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755542Ab3GUPAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 11:00:07 -0400
In-Reply-To: <CAJZOPZJaKbMhtN4JSi6ScaRtwUNMK69trCccsdZvA7=57cDknQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-07-21 at 14:10 +0300, Or Gerlitz wrote:
> On Sat, Jul 20, 2013 at 8:53 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> >
> > This patch adds a ndo for getting physical port of the device. Driver
> > which is aware of being virtual function of some physical port should
> > implement this ndo.
> >
> > Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> > ---
> >  include/linux/netdevice.h | 20 ++++++++++++++++++++
> >  net/core/dev.c            | 18 ++++++++++++++++++
> >  2 files changed, 38 insertions(+)
> >
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 0741a1e..726dec2 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -728,6 +728,16 @@ struct netdev_fcoe_hbainfo {
> >  };
> >  #endif
> >
> > +#define MAX_PHYS_PORT_ID_LEN 32
> > +
> > +/* This structure holds a unique identifier to identify the
> > + * physical port used by a netdevice.
> > + */
> > +struct netdev_phys_port_id {
> > +       unsigned char id[MAX_PHYS_PORT_ID_LEN];
> > +       unsigned char id_len;
> > +};
> 
> 
> So an integer (four bytes?) is OK here? does it need to be in certain
> byte order?

It's an arbitrary value but is supposed to be universally unique.  So
you could use, for example, the first non-volatile MAC address assigned
to the port (if there is one).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
