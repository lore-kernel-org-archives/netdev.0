From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH 1/3] vlan: adds vlan_dev_select_queue
Date: Thu, 18 Feb 2010 08:37:10 +0100
Message-ID: <1266478630.2877.9.camel@edumazet-laptop>
References: <20100217123606.18210.13602.stgit@localhost.localdomain>
	 <1266414675.3246.12.camel@edumazet-laptop>
	 <20100217.134330.48386140.davem@davemloft.net>
	 <1266446441.1891.96.camel@vi2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, vasu.dev@intel.com
To: Vasu Dev <vasu.dev@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:65300 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153Ab0BRHhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 02:37:17 -0500
Received: by fxm20 with SMTP id 20so8643278fxm.21
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 23:37:15 -0800 (PST)
In-Reply-To: <1266446441.1891.96.camel@vi2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 f=C3=A9vrier 2010 =C3=A0 14:40 -0800, Vasu Dev a =C3=A9c=
rit :
> > > ------------------
> > >=20
> > > For performance reason, we could avoid calling vlan_dev_select_qu=
eue()
> > > for real devices without ndo_select_queue() handler, this would n=
eed to
> > > mirror vlan_netdev_ops & vlan_netdev_accel_ops.
> > >=20
>=20
> This means vlan_netdev_ops & vlan_netdev_accel_ops not to be const
> anymore so that vlan_dev_select_queue() could be initialized to vlan =
ops
> based on real dev ndo_select_queue() present or not, should be okay t=
o
> be not const anymore. I'll update patch as suggested.

No they should stay const

I said you should mirror (copy if you prefer) the structure, one with a
NULL ndo_select_queue pointer, one with a ndo_select_queue =3D
vlan_dev_select_queue.

Both structures are const.

You must not dynamiucally change the structure, because the same machin=
e
might have a vlan over a device with no ndo_select_queue() method, and
another vlan over a device with a ndo_select_queue()

Thanks




