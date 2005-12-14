From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 01:12:23 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0512140042280.31720@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932232AbVLNJMZ@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


These set of patches provide a TCP/IP emergency communication mechanism that
could be used to guarantee high priority communications over a critical socket
to succeed even under very low memory conditions that last for a couple of
minutes. It uses the critical page pool facility provided by Matt's patches
that he posted recently on lkml.
	http://lkml.org/lkml/2005/12/14/34/index.html

This mechanism provides a new socket option SO_CRITICAL that can be used to
mark a socket as critical. A critical connection used for emergency
communications has to be established and marked as critical before we enter
the emergency condition.

It uses the __GFP_CRITICAL flag introduced in the critical page pool patches
to indicate an allocation request as critical and should be satisfied from the
critical page pool if required. In the send path, this flag is passed with all
allocation requests that are made for a critical socket. But in the receive
path we do not know if a packet is critical or not until we receive it and
find the socket that it is destined to. So we treat all the allocation
requests in the receive path as critical.

The critical page pool patches also introduces a global flag
'system_in_emergency' that is used to indicate an emergency situation(could be
a low memory condition). When this flag is set any incoming packets that belong
to non-critical sockets are dropped as soon as possible in the receive path.
This is necessary to prevent incoming non-critical packets to consume memory
from critical page pool.

I would appreciate any feedback or comments on this approach.

Thanks
Sridhar
