From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 12 Aug 2012 17:05:12 +0300
Message-ID: <20120812140511.GC6003@redhat.com>
References: <501C3527.6060809@mellanox.com>
 <20120803.143315.151094375569109262.davem@davemloft.net>
 <501C5328.4060301@mellanox.com>
 <20120803.163627.1867181085116225405.davem@davemloft.net>
 <50205DE0.7080706@mellanox.com>
 <87obmnfs4p.fsf@xmission.com>
 <871ujjfkb1.fsf@xmission.com>
 <CAJZOPZ+W0wfa38LejXt0gvBNa8Q6pWVZOs7xctHGRQXHAeMYPQ@mail.gmail.com>
 <87hasd7pbz.fsf@xmission.com>
 <CAJZOPZKVjxaf1Sqchm4X4nKhYLR5yxnMiTjmvx1n4OELu=jhbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Ali Ayoub <ali@mellanox.com>,
	David Miller <davem@davemloft.net>, ogerlitz@mellanox.com,
	roland@kernel.org, netdev@vger.kernel.org, sean.hefty@intel.com,
	erezsh@mellanox.co.il, dledford@redhat.com
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51254 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971Ab2HLOG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2012 10:06:27 -0400
Content-Disposition: inline
In-Reply-To: <CAJZOPZKVjxaf1Sqchm4X4nKhYLR5yxnMiTjmvx1n4OELu=jhbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 09, 2012 at 07:06:46AM +0300, Or Gerlitz wrote:
> Eric W. Biederman <ebiederm@xmission.com> wrote:
> > Or Gerlitz <or.gerlitz@gmail.com> writes:
> 
> >> To put things in place, DHCPv4 is supported with eIPoIB, the DHCP
> >> UDP/IP payload  isn't touched, only need to set the BOOTP broadcast
> >> flag in the dhcp server config file.
> 
> > Wrong.  DHCPv4 is broken over eIPoIB. Coming from ethernet
> > htype == 1 not 32 as required by RFC4390
> > hlen == 6 not 0 as required by RFC4390
> > The chaddr field is has 6 bytes of the ethernet mac address not the
> > required 16 bytes of 0. The client-identifier field is optional over ethernet.
> > An ethernet DHCPv4 client simply does not generate a dhcp packet that
> > conforms to RFC4390.
> >
> > Therefore DHCPv4 over eIPoIB is broken, and a dhcp server or relay
> > may reasonably look at the DHCP packet and drop it because it is garbage.
> >
> > You might find a forgiving dhcp server that doesn't drop insane packets
> > on the floor and tries to make things work.
> 
> Under the eIPoIB design, the VM DHCP interaction follows
> Ethernet DHCP, and not the IPoIB DHCP (RFC 4390).
> 
> The DHCP server has no reason to drop such packets.
> 
> DHCP is a L7 (L5 to be precise) construct, I don't see
> why that the fact IPoIB DHCP RFC exists, means/mandates
> the DHCP server to care on the link layer type.
> 
> Or.

For example DHCP server could be configured with
HW address/IP address table.

-- 
MST
