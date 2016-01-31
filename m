From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: bonding (IEEE 802.3ad) not working with qemu/virtio
Date: Sun, 31 Jan 2016 16:35:35 +0200
Message-ID: <20160131163457-mutt-send-email-mst@redhat.com>
References: <CAJO99TmB3957Wq3Cse7azgBxKeZ2BV6QihoyAsjUjyvzc-V8dQ@mail.gmail.com>
 <56ABDA3D.8040100@cumulusnetworks.com>
 <28285.1454103900@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	=?us-ascii?B?PT9VVEYtOD9RP0JqPWMzPWI4cm5hcl9OZXNzPz0=?=
	<bjornar.ness@gmail.com>, netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46491 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757218AbcAaOfj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jan 2016 09:35:39 -0500
Content-Disposition: inline
In-Reply-To: <28285.1454103900@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 01:45:00PM -0800, Jay Vosburgh wrote:
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>=20
> >On 01/25/2016 05:24 PM, Bj=F8rnar Ness wrote:
> >> As subject says, 802.3ad bonding is not working with virtio networ=
k model.
> >>=20
> >> The only errors I see is:
> >>=20
> >> No 802.3ad response from the link partner for any adapters in the =
bond.
> >>=20
> >> Dumping the network traffic shows that no LACP packets are sent fr=
om the
> >> host running with virtio driver, changing to for example e1000 sol=
ves
> >> this problem
> >> with no configuration changes.
> >>=20
> >> Is this a known problem?
> >>=20
> >[Including bonding maintainers for comments]
> >
> >Hi,
> >Here's a workaround patch for virtio_net devices that "cheats" the
> >duplex test (which is the actual problem). I've tested this locally
> >and it works for me.
> >I'd let the others comment on the implementation, there're other sig=
ns
> >that can be used to distinguish a virtio_net device so I'm open to s=
uggestions.
> >Also feedback if this is at all acceptable would be appreciated.
>=20
> 	Should virtio instead provide an arbitrary speed and full duplex
> to ethtool, as veth does?
>=20
> 	Creating a magic whitelist of devices deep inside the 802.3ad
> implementation seems less desirable.
>=20
> 	-J

Absolutely but why not tream DUPLEX_UNKNOWN as DUPLEX_FULL
and allow LACP?

> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
