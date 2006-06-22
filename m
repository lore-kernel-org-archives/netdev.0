From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Thu, 22 Jun 2006 15:11:27 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F15F55E2@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:13832 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030416AbWFVWLt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 18:11:49 -0400
Content-class: urn:content-classes:message
To: hadi@cyberus.ca, "Steve Wise" <swise@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> On Thu, 2006-22-06 at 15:40 -0500, Steve Wise wrote:
>> On Thu, 2006-06-22 at 15:43 -0400, jamal wrote:
>>> 
>>> No - what these 2 gents are saying was these events and
>>> infrastructure already exist.
>> 
>> Notification of the exact events needed does not exist today.
>> 
> 
> Ok, so you cant event make use of anything that already exists?
> Or is a subset of what you need already there?
> 
>> The key events, again, are:
>> 
>> - the neighbour entry mac address has changed.
>> 
>> 
>> - the next hop ip address (ie the neighbour) for a given dst_entry
>> has changed.
> 
> 
> I dont see a difference for the above two from an L2 perspective.
> Are you keeping track of IP addresses?
> You didn't answer my question in the previous email as to
> what RDMA needs to keep track of in hardware.
> 

The RDMA device is handling L4 or L5 connections that 
have L3 Addresses (IP). Subscribing to the information
allows the device to keep its behaviour consistent
with the host stack.

The common alternative before proposing this integration
was to have the RDMA device sniff all incoming packets
and attempt to do parallel procesing on a large set
of lower layer protocols (ICMP, ARP, routing, ...)
Or by simply trusting that the IB network adminstrator
has faithfully replicated all IP-relevent instructions
in two forums (traditional IP nework administration
and IB network administration).

These subscriptions are an attempt to cede full control
of these issues back to one place, the kernel, and to
guarantee that an offload device can never think that
the route to to X is Y when the kernel says it is Z.
Or that it has a different PMTU, etc.

I don't have any strong opinion on the best mechanism
for implementing these subscriptions, but having correct
consistent networking behaviour depend on a user-mode
relay strikes me as odd.



