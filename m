From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] net: add IFF_SKB_TX_SHARED flag to priv_flags
Date: Tue, 26 Jul 2011 10:54:21 -0400
Message-ID: <20110726145421.GA9238@hmsreliant.think-freely.org>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
 <1311623120-26839-1-git-send-email-nhorman@tuxdriver.com>
 <1311623120-26839-2-git-send-email-nhorman@tuxdriver.com>
 <1311624682.2996.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Robert Olsson <robert.olsson@its.uu.se>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58983 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385Ab1GZOyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 10:54:32 -0400
Content-Disposition: inline
In-Reply-To: <1311624682.2996.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 25, 2011 at 10:11:22PM +0200, Eric Dumazet wrote:
> Le lundi 25 juillet 2011 =E0 15:45 -0400, Neil Horman a =E9crit :
> > Pktgen attempts to transmit shared skbs to net devices, which can't=
 be used by
> > some drivers as they keep state information in skbs.  This patch ad=
ds a flag
> > marking drivers as being able to handle shared skbs in their tx pat=
h.  Drivers
> > are defaulted to being unable to do so, but calling ether_setup ena=
bles this
> > flag, as 90% of the drivers calling ether_setup touch real hardware=
 and can
> > handle shared skbs.  A subsequent patch will audit drivers to ensur=
e that the
> > flag is set properly
> >=20
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > Reported-by: Jiri Pirko <jpirko@redhat.com>
> > CC: Robert Olsson <robert.olsson@its.uu.se>
> > CC: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: Alexey Dobriyan <adobriyan@gmail.com>
> > CC: David S. Miller <davem@davemloft.net>
> > ---
> >  include/linux/if.h |    2 ++
> >  net/core/pktgen.c  |    8 +++++---
> >  net/ethernet/eth.c |    1 +
> >  3 files changed, 8 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/include/linux/if.h b/include/linux/if.h
> > index 3bc63e6..03489ca 100644
> > --- a/include/linux/if.h
> > +++ b/include/linux/if.h
> > @@ -76,6 +76,8 @@
> >  #define IFF_BRIDGE_PORT	0x4000		/* device used as bridge port */
> >  #define IFF_OVS_DATAPATH	0x8000	/* device used as Open vSwitch
> >  					 * datapath port */
> > +#define IFF_TX_SKB_SHARING	0x10000	/* The interface supports shari=
ng
> > +					 * skbs on transmit */
> > =20
> >  #define IF_GET_IFACE	0x0001		/* for querying only */
> >  #define IF_GET_PROTO	0x0002
> > diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> > index f76079c..53f3f15 100644
> > --- a/net/core/pktgen.c
> > +++ b/net/core/pktgen.c
> > @@ -1070,7 +1070,9 @@ static ssize_t pktgen_if_write(struct file *f=
ile,
> >  		len =3D num_arg(&user_buffer[i], 10, &value);
> >  		if (len < 0)
> >  			return len;
> > -
> > +		if ((len > 0) &&
>=20
> 		if ((value > 0) ...
>=20
Thank you Eric, I'll respin this shortly
Neil
