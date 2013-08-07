From: Erik Hugne <erik.hugne@ericsson.com>
Subject: skbs delivered to 'wrong' packet_type handler
Date: Wed, 7 Aug 2013 15:08:56 +0200
Message-ID: <20130807130856.GI3165@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:47565 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932908Ab3HGNI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 09:08:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a race condition in TIPC when using both the parent ethernet 
device, and a vlan on top of this device as TIPC bearers. For some reason, 
net/core/dev.c is delivering vlan packets to packet handlers registered to 
the native device. This only seems to occur when a packet_type handler is 
registered on both the vlan device and it's parent ethernet device. This 
causes all kinds of weird behaviour in TIPC, from cross-vlan links being 
established to oopses.

At first, i thought this was due to a missing PACKET_OTHERHOST filtering
in the TIPC ethernet code, but adding that check did not resolve the issue.
Adding an explicit check for skb->dev vs packet_type->dev does work, but
i dont think that's the proper way to solve it.
What's the purpose of having a dev entry in the packet_type if it's ignored 
by the lower layers?

//E
