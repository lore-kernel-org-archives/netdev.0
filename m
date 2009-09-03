From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: L2 switching in igb
Date: Thu, 3 Sep 2009 12:16:06 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0909031116070.22050@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Fischer, Anna" <anna.fischer@hp.com>, netdev@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:43869 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754687AbZICJQN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 05:16:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex, Jeff

I see that igb_vmm_control enables L2 switch functionality & replication of
multicast/broadcast packets across multiple pools (it calls both
igb_vmdq_set_loopback/replication_pf with true).

I wanted to check few related things with you:

First, what you think would be the correct method for letting the user control
if she wants the NIC to operate in VEPA mode (e.g forward VF/VF traffic to an
outside bridge and let the later do a Uturn) or to handle VF/VF traffic
internally? maybe it can be part or extension of the kernel DCB netlink API?

second, does igb_vmdq_set_replication_pf cause multicast packets to be
replicated to all VFs? I see that after invoking igb_vmm_control, there's
a call to igb_set_vmolr which sets the "Accept packets matched in MTA"
bit, so I wasn't sure what's is the final result, will the PF flood all
multicast packets and the VF accept only those that have a match in the MTA?

Or.
