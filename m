From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: RDMA will be reverted
Date: Thu, 6 Jul 2006 06:26:06 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F15F6122@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Tom Tucker" <tom@opengridcomputing.com>,
	"David Miller" <davem@davemloft.net>, rdreier@cisco.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:12806 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1030252AbWGFN0h convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 09:26:37 -0400
Content-class: urn:content-classes:message
To: "Andi Kleen" <ak@suse.de>, "Andy Gay" <andy@andynet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> 
>> We're focusing on netfilter here. Is breaking netfilter really the
>> only issue with this stuff?
> 
> Another concern is that it will just not be able to keep
> up with a high rate of new connections or a high number of them
> (because the hardware has too limited state)
> 

Neither iWARP or an iSCSI initiator will require extremely high
rates of connection establishment. An RNIC only establishes connections
when its services have been explicitly requested (via use of a specific
service).

In any event, the key question here is whether integration with
the netdevice improves things or whether the offload device should
be "totally transparent" to the kernel. If the offload device somehow
insisted on handling connection requests that the kernel would have
been able to handle then this would be an issue. But the kernel is
not currently handling RDMA Connect requests on its own, and I know
of no-one who has suggested that a software-only implementation of
RDMA is feasible at 10Gbit is feasible.

netfiler integration is definitely something that needs to be addressed,
but the L2/L3 integrations need to be in place first.

> And then there are the other issues I listed like subtle TCP bugs
> (TSO is already a nightmare in this area and it's still not quite
> right) etc. 
> 

Making an RNIC "fully transparent" to the kernell would require it
to handle many L2 and L3 issues in parallel with the host stack.
That increases the chance of a bug, or at least a subtle difference
between the host and the RNIC which while being compliant would
be unexpected.

The purposes of the proposed patches is to enable the RNIC to be
in full compliance with the host stack on IP layer issues.



> 
> It would need someone who can describe how this new RDMA device avoids
> all the problems, but so far its advocates don't seem to be interested
> in doing that and I cannot contribute more.
> 

RDMA services are already defined for the kernel. The connection
management and network notifier patches are about enabling RDMA
devices to use IP addresses in a way that is consistent.

Obviously doing so is more important for an iWARP device than for
an InfiniBand device, but each InfiniBand users have expressed a
desire to use IP addressing.

Applications do not use RDMA by accident, it is a major design
decision. Once an application uses RDMA it is no longer a direct
consumer of the transport layer protocol. Indeed, one of the
main objectives of the OpenFabrics stack is to enable typical
applications to be written that will work over RDMA without
caring what the underlying transport is. The options for control
will still be there, but just as a sockets programmer does not
typically care whether their IP is carried over SLIP, PPP,
Ethernet or ATM; most RDMA developers should not have to worry
about iWARP or InfiniBand.

http://ietf.org/internet-drafts/draft-ietf-rddp-applicability-08.txt
provides an overview on how RDMA benefits applications, and when
applications would benefit from its use as compared to plain TCP.

