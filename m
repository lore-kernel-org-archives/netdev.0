From: "Chiappero, Marco" <marco.chiappero@intel.com>
Subject: RE: [PATCH net-next 9/9] ipvlan: introduce individual MAC addresses
Date: Tue, 2 May 2017 15:08:28 +0000
Message-ID: <695CDAEB5A6CE2498DE413F2A9AA82960915DF0C@IRSMSX101.ger.corp.intel.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
         <20170427145142.15830-10-marco.chiappero@intel.com>
         <1493310033.27948.3.camel@redhat.com> <1493310219.27948.5.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: "David S . Miller" <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "Grandhi, Sainath" <sainath.grandhi@intel.com>,
        Mahesh Bandewar <maheshb@google.com>
To: 'Dan Williams' <dcbw@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:39256 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750769AbdEBPIr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 11:08:47 -0400
In-Reply-To: <1493310219.27948.5.camel@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: Dan Williams [mailto:dcbw@redhat.com]
> On Thu, 2017-04-27 at 11:20 -0500, Dan Williams wrote:
> > On Thu, 2017-04-27 at 15:51 +0100, Marco Chiappero wrote:
> > > Currently all the slave devices belonging to the same port inherit
> > > their MAC address from its master device. This patch removes this
> > > limitation and allows every slave device to obtain a unique MAC
> > > address, by default randomly generated at creation time.
> > >
> > > Moreover it is now possible to correctly modify the MAC address at
> > > any time, fixing an existing bug as MAC address changes on the
> > > master were not reflected on the slaves. It also avoids multiple
> > > interfaces sharing the same IPv6 link-local address.
> >
> > How is this different than macvlan now?

The same way it was before. The purpose of the patch is to make possible to change the MAC address on slaves, not to change the external behavior of ipvlan: ipvlan will still behave as ipvlan, macvlan will still behave as macvlan.

>>  Why would you use unique
> > addressed ipvlan instances instead of macvlan?  Wouldn't the same
> > problems around external switches not expecting multiple MACs from the
> > same switch port apply now to ipvlan?

No. I'm willing to rework the commit messages if this point is not clear.
The idea is to effectively NAT communications, which is more or less the whole concept behind ipvlan.

> > The whole point of ipvlan AIUI was to get around macvlan problems
> > related to multiple MACs on the same port.
> 
> Another issue is the unicast MAC limits on cards.  ipvlan is now much more likely
> to hit the unicast MAC limit of the NIC and thus trigger promiscuous mode and
> the resulting performance drop, where before it would not.

The outside world will still see and use only one unicast MAC address, belonging to the master interface. No need to store any other unicast MAC in the filter.

Multicast filters will work as before, the only difference is that now slaves have different IPv6 link-local addresses, with an associated L2 multicast address). If this turns out to be an issue it's possible to keep the same MAC address by default but still allow it change. Or maybe force the same default link-local address somehow.
 
However, if the MAC filter is really the issue, I strongly encourage you to start working with HW vendors in order to better support modern data center workloads as a long term solution.

> > Also, I think the IPv6 thing you mention is incorrect and has long
> > since been solved.  Originally, ipvlan did not include a "dev_id"
> > property that differened between child interfaces, and thus the IID of
> > the each interface was the same.  That has now been fixed, and each
> > ipvlan slave should now have a different IID and thus a different
> > link-
> > local address.

Yes, thank you for pointing it out. I started this change a few months ago when such fix not present and simply rebased lately without noticing it.

Please let me know if you have further questions.

Thank you,
Marco
--------------------------------------------------------------
Intel Research and Development Ireland Limited
Registered in Ireland
Registered Office: Collinstown Industrial Park, Leixlip, County Kildare
Registered Number: 308263


This e-mail and any attachments may contain confidential material for the sole
use of the intended recipient(s). Any review or distribution by others is
strictly prohibited. If you are not the intended recipient, please contact the
sender and delete all copies.
