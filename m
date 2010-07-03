From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] IB/{nes,ipoib}: Pass supported flags to ethtool_op_set_flags()
Date: Sat, 03 Jul 2010 13:08:29 -0700
Message-ID: <adask40nxaa.fsf@roland-alpha.cisco.com>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
	<20100702095514.7fb324c8.randy.dunlap@oracle.com>
	<20100702.220711.39188625.davem@davemloft.net>
	<20100703120729.f2a2715b.randy.dunlap@oracle.com>
	<1278184884.4878.559.camel@localhost>
	<1278186089.4878.570.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-net-drivers-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	amit.salecha-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	anirban.chakraborty-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, scofeldm-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org,
	vkolluri-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, roprabhu-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org,
	e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org,
	gallatin-vV262kQ/Wyo@public.gmane.org, brice-vV262kQ/Wyo@public.gmane.org, shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	jgarzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Chien Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1278186089.4878.570.camel@localhost> (Ben Hutchings's message of
	"Sat, 03 Jul 2010 20:41:29 +0100")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 > Following commit 1437ce3983bcbc0447a0dedcd644c14fe833d266 "ethtool:
 > Change ethtool_op_set_flags to validate flags", ethtool_op_set_flags
 > takes a third parameter and cannot be used directly as an
 > implementation of ethtool_ops::set_flags.

I assume this commit is in one of Dave's trees and breaks nes and ipoib
because it changed the ethtool_op_set_flags prototype?

 > Dave, Roland, you'd better decide between yourselves should apply this.

Since this depends on a commit already in Dave's tree, Dave should
probably take it into the same tree.  I guess there's no way to roll
this into the original patch to avoid breaking bisects once this ends up
upstream?

anyway,

Acked-by: Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>

 > +static int nes_netdev_set_flags(struct net_device *netdev, u32 flags)
 > +{
 > +	return ethtool_op_set_flags(netdev, flags, ETH_FLAG_LRO);
 > +}
 > +
 > +
 >  static const struct ethtool_ops nes_ethtool_ops = {

Also would have been a bit nicer to avoid adding a double blank line
here, although that's obviously a trivial issue.

 - R.
-- 
Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
