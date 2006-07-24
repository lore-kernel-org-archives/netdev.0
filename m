From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: RDMA will be reverted
Date: Mon, 24 Jul 2006 15:47:50 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F17443F3@NT-SJCA-0751.brcm.ad.broadcom.com>
References: <20060724.152533.62664432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: tom@opengridcomputing.com, ak@suse.de, rdreier@cisco.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:56584 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932310AbWGXWsK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 18:48:10 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20060724.152533.62664432.davem@davemloft.net>
To: "David Miller" <davem@davemloft.net>, swise@opengridcomputing.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> From: Steve Wise <swise@opengridcomputing.com>
> Date: Wed, 05 Jul 2006 12:50:34 -0500
> 
>> However, iWARP devices _could_ integrate with netfilter.  For most
>> devices the connection request event (SYN) gets passed up to the host
>> driver.  So the driver can enforce filter rules then.
> 
> This doesn't work.  In order to handle things like NAT and
> connection tracking properly you must even allow ESTABLISHED
> state packets to pass through netfilter.
> 
> Netfilter can have rules such as "NAT port 200 to 300, leave
> the other fields alone" and your suggested scheme cannot handle this.

This is totally irrelevant. But it does work.

First, an RDMA connection once established associates a
TCP connection *as identified external to the box* with
an RDMA endpoint (conventionally a "QP").

Performing a NAT translation on a TCP packet would certainly
be within the capabilities of an RNIC, but it would be pointless.
The relabeled TCP segment would be associated with the same QP.

Once an RDMA connection is established, the individual TCP segments
are only of interest to the RDMA endpoint. Payload is delivered
through the RDMA interface (the same one already used for
InfiniBand). The purpose of integration with netfilter would
be to ensure that no RDMA Connection could exist, or persist,
if netfilter would not allow the TCP connection to be created.

That is not a matter of packet filtering, it is matter of
administrative consistency. If someone uses netfilter to block
connections from a given IP netmask then they reasonably expect
that there will be no connections with any host within that
IP netmask. They do not expect exceptions for RDMA, iSCSI
or InfiniBand.

The existing connection management interfaces in openfabrics,
designed to support both InfiniBand and iWARP, could naturally
be extended to validate all RDMA connections using an IP address
with netfilter. This would be of real value.

The only real value of a rule such as "NAT port 200 to 300" is
to allow a remote peer to establish a connection to port 200
with a local listener using port 300. That *can* be supported
without actually manipulating the header in each TCP packet.

It is also possible to discuss other netfilter functionality
that serves a valid end-user purpose, such as counting packets.
 

