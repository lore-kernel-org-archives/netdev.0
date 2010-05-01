From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 PATCH 2/2] add ndo_set_port_profile op support for enic dynamic vnics
Date: Sat, 1 May 2010 14:36:49 +0200
Message-ID: <201005011436.49879.arnd@arndb.de>
References: <C8008CCC.2D21E%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:60960 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238Ab0EAMhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 08:37:09 -0400
In-Reply-To: <C8008CCC.2D21E%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 30 April 2010, Scott Feldman wrote:
> >    ip iov set  port-profile DEVICE [ base BASE-DEVICE ] name PORT-PROFILE
> >                              [ host_uuid HOST_UUID ]
> >                      [ client_name CLIENT_NAME ]
> >                                       [ client_uuid CLIENT_UUID ]
> >    ip iov set  vsi { associate | pre-associate | pre-associate-rr }
> > BASE-DEVICE
> >                                       vsi MGR:VTID:VER
> >                                       mac LLADDR [ vlan VID ]
> >                                       client_uuid CLIENT_UUID
> > 
> >    ip iov del  port_profile DEVICE      [ base BASE-DEVICE ]
> >    ip iov del  vsi          BASE-DEVICE [ mac LLADDR [ vlan VID ] ]
> >        [ client_uuid CLIENT_UUID ]
> > 
> >    ip iov show port_profile DEVICE      [ base BASE-DEVICE ]
> >    ip iov show vsi          BASE-DEVICE [ mac LLADDR [ vlan VID ] ]
> > [ client_uuid CLIENT_UUID ]
> > 
> > You would obvioulsy only implement the kernel support for the port-profile
> > stuff as callbacks, because no driver yet does VDP in the kernel, but we
> > should
> > have a common netlink header that defines both variants.
> > 
> > Chris, any opinion on this interface as opposed to the combined one?
> > Either one should work, but splitting it seems cleaner to me.
> 
> I haven't seen Chris's response, but it seems vger was down for awhile, so
> maybe it's coming.  Assuming we go for the split design, we're still talking
> about using RTM_SETLINK/RTM_GETLINK/RTM_DELLINK for these netlink msgs?  Or
> are you suggesting by your cmd syntax that we return to
> RTM_SETIOV/RTM_GETIOV like in the first iovnl patch?  RTM_SET/GET/DELLINK is
> probably simplier, cleaner patch.

In either case (split or combined), I would prefer the separate IOV
commands. The reason for this is that when support is not in the kernel,
it allows a cleaner separation between what's (always) handled in the
kernel and what's (potentially) done in user space.

	Arnd
