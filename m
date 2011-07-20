From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Wed, 20 Jul 2011 12:36:31 -0400
Message-ID: <20110720163631.GI12349@hmsreliant.think-freely.org>
References: <1311105738.3113.11.camel@edumazet-laptop>
 <20110719202922.GA2352@minipsycho>
 <1311108107.3113.22.camel@edumazet-laptop>
 <20110720001904.GA1992@neilslaptop.think-freely.org>
 <1311122593.3113.46.camel@edumazet-laptop>
 <4E2626E1.6030005@candelatech.com>
 <20110720020737.GB2692@neilslaptop.think-freely.org>
 <1311135855.3113.66.camel@edumazet-laptop>
 <20110720151827.GD12349@hmsreliant.think-freely.org>
 <4E270350.7050904@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, robert.olsson@its.uu.se
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55881 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740Ab1GTQg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 12:36:56 -0400
Content-Disposition: inline
In-Reply-To: <4E270350.7050904@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 09:33:20AM -0700, Ben Greear wrote:
> On 07/20/2011 08:18 AM, Neil Horman wrote:
> >On Wed, Jul 20, 2011 at 06:24:15AM +0200, Eric Dumazet wrote:
> >>Le mardi 19 juillet 2011 =E0 22:07 -0400, Neil Horman a =E9crit :
> >>>>
> >>>I think this is a good idea.  It lets pktgen dynamically make the =
clone/share
> >>>decision dynamically and only impacts performance for those system=
s.
> >>>
> >>
> >>Just let pktgen refuse to use clone_skb command for these devices.
> >>
> >copy that, This is by no means final, but what do you think of this?=
  If its
> >agreeable to you, Ben, et al. I can add this to my local tree and st=
art auditing
> >all the drivers that may need to have the flag set.
> >
> >Regards
> >Neil
> >
> >
> >diff --git a/include/linux/if.h b/include/linux/if.h
> >index 3bc63e6..ae904fe 100644
> >--- a/include/linux/if.h
> >+++ b/include/linux/if.h
> >@@ -76,6 +76,7 @@
> >  #define IFF_BRIDGE_PORT	0x4000		/* device used as bridge port */
> >  #define IFF_OVS_DATAPATH	0x8000	/* device used as Open vSwitch
> >  					 * datapath port */
> >+#define IFF_CANT_SHARE_SKB	0x10000	/* Device can't share skbs in tx=
 path */
> >
> >  #define IF_GET_IFACE	0x0001		/* for querying only */
> >  #define IF_GET_PROTO	0x0002
> >diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> >index f76079c..bf6d88d 100644
> >--- a/net/core/pktgen.c
> >+++ b/net/core/pktgen.c
> >@@ -1071,6 +1071,9 @@ static ssize_t pktgen_if_write(struct file *fi=
le,
> >  		if (len<  0)
> >  			return len;
> >
> >+		if (pkt_dev->priv_flags&  IFF_CANT_SHARE_SKB)
> >+			return -EOPNOTSUPP;
> >+
> >  		i +=3D len;
> >  		pkt_dev->clone_skb =3D value;
> >
>=20
> Please only return an error if value > 1.
>=20
> Also, if there is any place where user can configure pkt_dev,
> you would want code there to check for the CANT_SHARE_SKB flag
> and force clone_skb to zero if user changes to a different
> device that cannot share skbs.
>=20
> Thanks,
> Ben
>=20
Understood, thank you Ben.
Neil

> --=20
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
>=20
>=20
