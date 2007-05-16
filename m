From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: Re: [patch 2/7] CAN: Add PF_CAN core module
Date: Wed, 16 May 2007 20:26:34 +0200
Message-ID: <464B4CDA.1030906@hartkopp.net>
References: <20070516145100.29877.0@janus.isnogud.escape.de> <20070516145121.29877.2@janus.isnogud.escape.de> <39e6f6c70705160935q66109a3ci414374544d99c78f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	"Hartkopp, Oliver \(K-EFE/E\)" <oliver.hartkopp@volkswagen.de>,
	"Thuermann, Urs, Dr. \(K-EFE/I\)" <urs.thuermann@volkswagen.de>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:16512 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395AbXEPS1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 14:27:21 -0400
In-Reply-To: <39e6f6c70705160935q66109a3ci414374544d99c78f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
>
> <SNIP>
>
> > +
> > +/**
> > + * struct sockaddr_can - the sockaddr structure for CAN sockets
> > + * @can_family:  address family number AF_CAN.
> > + * @can_ifindex: CAN network interface index.
> > + * @can_addr:    transport protocol specific address, mostly CAN IDs.
> > + */
> > +struct sockaddr_can {
> > +       sa_family_t can_family;
> > +       int         can_ifindex;
> > +       union {
> > +               struct { canid_t rx_id, tx_id; } tp16;
> > +               struct { canid_t rx_id, tx_id; } tp20;
> > +               struct { canid_t rx_id, tx_id; } mcnet;
> > +               struct { canid_t rx_id, tx_id; } isotp;
> > +               struct { int     lcu,   type;  } bap;
> > +       } can_addr;
> > +};
>
> Can can_ifindex be turned into a unsigned short?
>

Hm - did you ever search for ifindex in the kernel?
E.g. in struct net_device in include/linux/netdevice.h , or functions 
like dev_get_by_index() ?

The interface index (ifindex) is always(!) defined as an integer.
I think, we would get rightly knocked defining ifindex as a short value ;-)

Regards,
Oliver


