From: Donald Becker <becker@scyld.com>
Subject: Re: NAPI for eepro100
Date: Wed, 12 Jun 2002 22:25:22 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae9026$n00$2@main.gmane.org>
References: <20020612.163344.31410429.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, <linux-mips@oss.sgi.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020612.163344.31410429.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Wed, 12 Jun 2002, David S. Miller wrote:
>    From: Jeff Garzik <jgarzik@mandrakesoft.com>
>    Oh crap, you're right...   eepro100 in general does funky stuff with the
>    way packets are handled, mainly due to the need to issue commands to the
>    NIC engine instead of the normal per-descriptor owner bit way of doing
>    things.

The eepro100 has a unique design in many different aspects.

> The question is, do the descriptor bits have to live right before
> the RX packet data buffer or can other schemes be used?

With the current driver structure, yes, the descriptor words must be
immediately before the packet data.  You can use other Rx and Tx
structures/modes to avoid this, but they use less efficient memory access.
For instance, the current Tx structure allows transmitting a packet with
a single PCI burst, rather than multiple transfers.


-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Second Generation Beowulf Clusters
Annapolis MD 21403			410-990-9993
