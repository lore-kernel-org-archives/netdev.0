From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 4/4] bridge: vlan: combine (br|nbp)_vlan_flush
 into one
Date: Mon, 12 Oct 2015 15:49:49 -0400
Message-ID: <20151012194949.GA2325@ketchup.lan>
References: <1444650069-32572-1-git-send-email-razor@blackwall.org>
 <1444650069-32572-5-git-send-email-razor@blackwall.org>
 <20151012175156.GA16784@colbert.mtl.com>
 <20151012181539.GA30057@ketchup.lan>
 <20151012182713.GA17416@colbert.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nikolay Aleksandrov <razor@blackwall.org>, sfeldma@gmail.com,
	netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:53873 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbbJLT4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 15:56:54 -0400
Content-Disposition: inline
In-Reply-To: <20151012182713.GA17416@colbert.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct. Monday 12 (42) 09:27 PM, Ido Schimmel wrote:
> Mon, Oct 12, 2015 at 09:15:39PM IDT, vivien.didelot@savoirfairelinux.com wrote:
> >Hi,
> >
> >On Oct. Monday 12 (42) 08:51 PM, Ido Schimmel wrote:
> >> Mon, Oct 12, 2015 at 02:41:09PM IDT, razor@blackwall.org wrote:
> >> >From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> >> >
> >> >As Ido Schimmel pointed out the vlan_vid_del() loop in nbp_vlan_flush is
> >> >unnecessary (and is actually a remnant of the old vlan code) so we can
> >> >remove it and combine both br/nbp vlan_flush functions into one.
> >> Just a small note to Scott and Vivien:
> >> 
> >> One of the side effects of Nik's recent patchsets is that when VLANs are
> >> flushed on a port the deletion is propagated to the driver via
> >> switchdev ops, as __vlan_vid_del is called.
> >> 
> >> Therefore there is no need to do internal bookkeeping and remove VLANs
> >> yourself when port is removed from bridge.
> >
> >I was thinking about caching VLAN entries in the mv88e6xxx driver to
> >improve look up on VLAN and FDB operations, but it's a bit prematurate.
> >
> >But when VLAN are flushed, we still need to remove them from the
> >hardware table, right?
> Hi,
> 
> Not sure I'm following. You'll simply get a SWITCHDEV_OBJ_ID_PORT_VLAN
> (del) for each VLAN configured on the port you just removed from the bridge.
> I guess you remove them from your hardware table in the implementation
> of these ops?

Yes we do remove VLAN entries from the hardware table when
switchdev_port_obj_del(SWITCHDEV_OBJ_ID_PORT_VLAN) is called.

I may have misunderstood your previous note, I thought we were talking
about implementing the flush operation in switchdev drivers.

> >
> >Flushing is interesting though, most hardware have flush operations and
> >it would be interesting to have switchdev fdb_flush and vlan_flush ops.

Thanks,
-v
