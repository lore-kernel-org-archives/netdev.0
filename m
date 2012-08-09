From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Thu, 9 Aug 2012 07:06:46 +0300
Message-ID: <CAJZOPZKVjxaf1Sqchm4X4nKhYLR5yxnMiTjmvx1n4OELu=jhbg@mail.gmail.com>
References: <501C3527.6060809@mellanox.com>
	<20120803.143315.151094375569109262.davem@davemloft.net>
	<501C5328.4060301@mellanox.com>
	<20120803.163627.1867181085116225405.davem@davemloft.net>
	<50205DE0.7080706@mellanox.com>
	<87obmnfs4p.fsf@xmission.com>
	<871ujjfkb1.fsf@xmission.com>
	<CAJZOPZ+W0wfa38LejXt0gvBNa8Q6pWVZOs7xctHGRQXHAeMYPQ@mail.gmail.com>
	<87hasd7pbz.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ali Ayoub <ali@mellanox.com>, David Miller <davem@davemloft.net>,
	ogerlitz@mellanox.com, roland@kernel.org, netdev@vger.kernel.org,
	sean.hefty@intel.com, erezsh@mellanox.co.il, dledford@redhat.com,
	"Michael S. Tsirkin" <mst@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:48245 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab2HIEGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 00:06:47 -0400
Received: by yenl2 with SMTP id l2so20103yen.19
        for <netdev@vger.kernel.org>; Wed, 08 Aug 2012 21:06:47 -0700 (PDT)
In-Reply-To: <87hasd7pbz.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> wrote:
> Or Gerlitz <or.gerlitz@gmail.com> writes:

>> To put things in place, DHCPv4 is supported with eIPoIB, the DHCP
>> UDP/IP payload  isn't touched, only need to set the BOOTP broadcast
>> flag in the dhcp server config file.

> Wrong.  DHCPv4 is broken over eIPoIB. Coming from ethernet
> htype == 1 not 32 as required by RFC4390
> hlen == 6 not 0 as required by RFC4390
> The chaddr field is has 6 bytes of the ethernet mac address not the
> required 16 bytes of 0. The client-identifier field is optional over ethernet.
> An ethernet DHCPv4 client simply does not generate a dhcp packet that
> conforms to RFC4390.
>
> Therefore DHCPv4 over eIPoIB is broken, and a dhcp server or relay
> may reasonably look at the DHCP packet and drop it because it is garbage.
>
> You might find a forgiving dhcp server that doesn't drop insane packets
> on the floor and tries to make things work.

Under the eIPoIB design, the VM DHCP interaction follows
Ethernet DHCP, and not the IPoIB DHCP (RFC 4390).

The DHCP server has no reason to drop such packets.

DHCP is a L7 (L5 to be precise) construct, I don't see
why that the fact IPoIB DHCP RFC exists, means/mandates
the DHCP server to care on the link layer type.

Or.
