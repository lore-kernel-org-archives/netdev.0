From: Stephen Hemminger <stephen@networkplumber.org>
Subject: NDA_PORT attribute is useless
Date: Fri, 17 May 2013 20:54:57 -0700
Message-ID: <20130517205457.61dbaae2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:62758 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306Ab3ERDzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 23:55:02 -0400
Received: by mail-da0-f51.google.com with SMTP id h15so2748988dan.10
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 20:55:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed that this commit is also broken.
Because although you can specify alternate UDP ports for sending,
it does nothing to enable those ports for reception. So although you
can create new static neighbour entries with different ports, they
are useless.

commit 6681712d67eef14c4ce793561c3231659153a320
Author: David Stevens <dlstevens@us.ibm.com>
Date:   Fri Mar 15 04:35:51 2013 +0000

    vxlan: generalize forwarding tables
    
    This patch generalizes VXLAN forwarding table entries allowing an administra
    to:
        1) specify multiple destinations for a given MAC
        2) specify alternate vni's in the VXLAN header
        3) specify alternate destination UDP ports
        4) use multicast MAC addresses as fdb lookup keys
        5) specify multicast destinations
        6) specify the outgoing interface for forwarded packets
    
    The combination allows configuration of more complex topologies using VXLAN
    encapsulation.
    
    Changes since v1: rebase to 3.9.0-rc2
    
