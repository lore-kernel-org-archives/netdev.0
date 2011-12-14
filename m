From: Vasu Dev <vasu.dev@linux.intel.com>
Subject: Re: [PATCH] net: do not pass vlan pkts to real dev pkt handler also
Date: Wed, 14 Dec 2011 15:55:23 -0800
Message-ID: <1323906923.8333.64.camel@vi>
References: <20111212221923.5356.43629.stgit@vifc.jf.intel.com>
	 <20111212225622.GA7083@minipsycho> <1323738532.8333.7.camel@vi>
	 <20111213142114.GB2702@minipsycho> <1323796263.8333.20.camel@vi>
	 <20111213214537.GC2702@minipsycho>  <4EE8FE86.90009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, Vasu Dev <vasu.dev@intel.com>,
	netdev@vger.kernel.org, devel@open-fcoe.org, eric.dumazet@gmail.com
To: Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18729 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755628Ab1LOAm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Dec 2011 19:42:56 -0500
In-Reply-To: <4EE8FE86.90009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-14 at 20:52 +0100, Nicolas de Peslo=C3=BCan wrote:
> If a protocol handler is registered on a particular device (instead o=
f
> NULL), then the handler will=20
> receive whatever is received on this device. This is true for bridge,
> for bonding and probably for=20
> all other "stackable" devices. I don't see any reason to handle it in
> a different way for vlan.
>=20

Yeah okay to have orig_dev pkt handler see its all vlan frames though w=
e
didn't have that way until recent change but seems reasonable to have
this way now. So I'll fix fcoe by allowing frames matching to its own
device and that will exclude vlan frames on its orig_dev pkt handler.

However now each stacked vlan tag iteration would result in passing up
frame to its orig_dev pkt handler but don't know if that affects other
and anyway fcoe would be okay with that as well.

Thanks
Vasu
