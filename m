From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: in-driver QoS
Date: Mon, 14 Jun 2004 23:53:26 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406142353.28277.vkondra@mail.ru>
References: <20040608184831.GA18462@bougret.hpl.hp.com> <200406111619.40260.vkondra@mail.ru> <1086960639.1068.697.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1086960639.1068.697.camel@jzny.localdomain>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal,
let's list the features need to be provided for 802.11 QoS, and problems.

It is worth to provide standard interface with wireless stack; otherwise each 
driver will invent its own solution.

1. NIC have number of Tx DMA channels, with different channels used for 
different priorities. It is dictated by standard (TGe).

Most likely, it should be 4 queues for EDCA traffic (4 priorities), 1 for HCCA 
(polled, pre-agreed streams) and optionally 1 for multicast traffic (AP need 
it).

Each queue need to start/stop separately. For flexibility, it should be some 
way for driver to request queues and specify mapping to these queues.

Ideas for how to implement it in stack?

Meanwhile, ideas how to get separate per-priority control with existing 
infrastructure?

2. There is traffic that require admission control. Unless driver performs 
allocation with AP, this traffic is not allowed. TGe standard dictates it.

Driver should participate in bandwidth allocation (via RSVP?). It should get 
some form of request (IOCTL?) which it will serve by performing allocation on 
link layer. It is easy to do proprietary IOCTL and white custom RSVP daemon, 
but it is much better to do something generic for all drivers to use.

Vladimir.
