From: Thomas Q Klein <TKLEIN@de.ibm.com>
Subject: Re: [PATCH 2.6.22-rc4] ehea: Fixed possible kernel panic on VLAN	packet
 recv
Date: Thu, 7 Jun 2007 10:14:42 +0200
Message-ID: <OF26993092.A6D2FCCC-ONC12572F3.002C9D0F-C12572F3.002D3FB4@de.ibm.com>
References: <1181176500.4166.1.camel@concordia.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>,
	tklein@linux.ibm.com
To: michael@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:23282 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbXFGIO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 04:14:58 -0400
In-Reply-To: <1181176500.4166.1.camel@concordia.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Ellerman <michael@ellerman.id.au> wrote on 06/07/2007 02:35:00 AM:

> On Wed, 2007-06-06 at 20:53 +0200, Thomas Klein wrote:
> > This patch fixes a possible kernel panic due to not checking the vlan
group
> > when processing received VLAN packets and a malfunction in
VLAN/hypervisor
> > registration.
> >
> >
> > Signed-off-by: Thomas Klein <tklein@de.ibm.com>
> > ---
> >
> >
> > diff -Nurp -X dontdiff linux-2.6.22-rc4/drivers/net/ehea/ehea.h
> patched_kernel/drivers/net/ehea/ehea.h
> > --- linux-2.6.22-rc4/drivers/net/ehea/ehea.h   2007-06-05 02:57:
> 25.000000000 +0200
> > +++ patched_kernel/drivers/net/ehea/ehea.h   2007-06-06 12:53:58.
> 000000000 +0200
> > @@ -39,7 +39,7 @@
> >  #include <asm/io.h>
> >
> >  #define DRV_NAME   "ehea"
> > -#define DRV_VERSION   "EHEA_0061"
> > +#define DRV_VERSION   "EHEA_0064"
> >
> >  #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
> >     | NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
> > diff -Nurp -X dontdiff linux-2.6.22-
> rc4/drivers/net/ehea/ehea_main.c
patched_kernel/drivers/net/ehea/ehea_main.c
> > --- linux-2.6.22-rc4/drivers/net/ehea/ehea_main.c   2007-06-05 02:
> 57:25.000000000 +0200
> > +++ patched_kernel/drivers/net/ehea/ehea_main.c   2007-06-06 12:
> 53:58.000000000 +0200
> > @@ -1947,7 +1945,7 @@ static void ehea_vlan_rx_add_vid(struct
> >     }
> >
> >     index = (vid / 64);
> > -   cb1->vlan_filter[index] |= ((u64)(1 << (vid & 0x3F)));
> > +   cb1->vlan_filter[index] |= ((u64)(0x8000000000000000 >> (vid &
0x3F)));
> >
> >     hret = ehea_h_modify_ehea_port(adapter->handle,
port->logical_port_id,
> >                     H_PORT_CB1, H_PORT_CB1_ALL, cb1);
> > @@ -1982,7 +1980,7 @@ static void ehea_vlan_rx_kill_vid(struct
> >     }
> >
> >     index = (vid / 64);
> > -   cb1->vlan_filter[index] &= ~((u64)(1 << (vid & 0x3F)));
> > +   cb1->vlan_filter[index] &= ~((u64)(0x8000000000000000 >> (vid &
0x3F)));
>
> These two seem ripe for splitting into some sort of helper routine.
> Which would leave only one place to get it right.
>
Basically agreed. But as we're already at rc4 I wanted to keep the
patch as least invasive as possible. The modification you suggest
can be implemented as a code improvement in 2.6.23.

