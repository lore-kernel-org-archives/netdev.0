From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH] vlan: propogate MTU changes (v2)
Date: Mon, 06 Oct 2008 20:20:48 +0100
Message-ID: <1223320848.3984.93.camel@achroite>
References: <20081006173024.2741cc01@speedy>	<48EA369F.3090306@trash.net>
	 <20081006195446.1dc5a372@speedy> <20081006202554.11354b09@speedy>
	 <80769D7B14936844A23C0C43D9FBCF0F16EF1C81@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:50588 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754980AbYJFTU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 15:20:56 -0400
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F16EF1C81@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-10-06 at 11:45 -0700, Duyck, Alexander H wrote:
> Stephen Hemminger wrote:
> > Propogate MTU changes of underlying device to all VLAN's and
> > send vlan MTU change out to userspace.
> >
> > see: https://bugzilla.vyatta.com/show_bug.cgi?id=3742
> >
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> >
> > --- a/net/8021q/vlan.c  2008-10-06 17:03:58.000000000 +0200
> > +++ b/net/8021q/vlan.c  2008-10-06 19:55:43.000000000 +0200
> > @@ -477,6 +477,17 @@ static int vlan_device_event(struct noti
> >
> >                 break;
> >
> > +       case NETDEV_CHANGEMTU:
> > +               /* Propogate MTU of underlying device */
> > +               for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
> > +                       vlandev = vlan_group_get_device(grp, i);
> > +                       if (!vlandev)
> > +                               continue;
> > +
> > +                       dev_set_mtu(vlandev, dev->mtu);
> > +               }
> > +               break;
> > +
> >         case NETDEV_DOWN:
> >                 /* Put all VLANs for this dev in the down state too.
> >                 */ for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
> 
> It has been a while since I worked with vlan tags, but I was just
> curious.  Shouldn't the vlan mtu be set to dev->mtu - VLAN_HLEN?
> 
> It seems like if the vlan and the device have the same mtu then
> you will always have issues since adding the vlan tag will
> increase the overall size and push the packet outside mtu size.

An MTU of 1500 is commonly taken to correspond to the IEEE 802.3 maximum
frame size of 1518 bytes which allows for a VLAN tag, and more generally
maximum frame size is set to MTU + 18.  However, not all drivers agree
with this interpretation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

