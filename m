From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: RDMA will be reverted
Date: Mon, 24 Jul 2006 15:57:54 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F17443F7@NT-SJCA-0751.brcm.ad.broadcom.com>
References: <20060724.152353.31604681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: ak@suse.de, rdreier@cisco.com, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:42507 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932314AbWGXW6Q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 18:58:16 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20060724.152353.31604681.davem@davemloft.net>
To: "David Miller" <davem@davemloft.net>, tom@opengridcomputing.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> From: Tom Tucker <tom@opengridcomputing.com>
> Date: Wed, 05 Jul 2006 12:09:42 -0500
> 
>> "A TOE net stack is closed source firmware. Linux engineers have no
>> way to fix security issues that arise. As a result, only non-TOE
>> users will receive security updates, leaving random windows of
>> vulnerability for each TOE NIC's users." 
>> 
>> - A Linux security update may or may not be relevant to a vendors
>> implementation. 
>> 
>> - If a vendor's implementation has a security issue then the customer
>> must rely on the vendor to fix it. This is no less true for iWARP
>> than for any adapter.
> 
> This isn't how things actually work.
> 
> Users have a computer, and they can rightly expect the
> community to help them solve problems that occur in the
> upstream kernel.
> 
> When a bug is found and the person is using NIC X, we don't
> necessarily forward the bug report to the vendor of NIC X.
> Instead we try to fix the bug.  Many chip drivers are
> maintained by people who do not work for the company that
> makes the chip, and this works just fine.
> 
> If only the chip vendor can fix a security problem, this
> makes Linux less agile to fix.  Even aspect of a problem on a
> Linux system that cannot be fixed entirely by the community
> is a net negative for Linux.
> 
>> - iWARP needs to do protocol processing in order to validate and
>> evaluate TCP payload in advance of direct data placement. This
>> requirement is independent of CPU speed.
> 
> Yet, RDMA itself is just an optimization meant to deal with
> limitations of cpu and memory speed.  You can rephrase the
> situation in whatever way suits your argument, but it does
> not make the core issue go away :)
> 

RDMA is a protocol that allows the application to more
precisely state the actual ordering requirements. It
improves the end-to-end interactions and has value
over a protocol with only byte or message stream
semantics regardless of local interface efficiencies.
See http://ietf.org/internet-drafts/draft-ietf-rddp-applicability-08.txt

In any event, isn't the value of an RDMA interface to applications
already settled? The question is how best to deal integrate the
usage of IP addresses with the kernel. The inability to validate
the low-level packet validation in open source code is a limitation
of *all* RDMA solutions, the transport layer of InfiniBand is just
as offloaded as it is for iWARP.

The patches proposed are intended to support integrated connection
management for RDMA connections using IP addresses, no matter what
the underlying transport is. The only difference is that *all* iWARP
connections use IP addresses.




