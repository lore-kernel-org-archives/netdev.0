From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: PROBLEM: Bridging does not work with Mellanox ConnectX-2
 (mlx4_en) card in SR-IOV mode
Date: Mon, 24 Jun 2013 09:48:04 -0700
Message-ID: <20130624094804.00003b32@unknown>
References: <CAJA5wJQDRztwtMxJopUWfmqEOH39Xp0g-hCrY8gMZ2TKccSuhw@mail.gmail.com>
	<20130624084259.4c2211a4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Pawit Pornkitprasan <p.pawit@gmail.com>, <netdev@vger.kernel.org>,
	"Ryousei Takano" <takano-ryousei@aist.go.jp>,
	Amir Vadai <amirv@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35108 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751784Ab3FXQsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 12:48:09 -0400
In-Reply-To: <20130624084259.4c2211a4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Jun 2013 08:42:59 -0700
Stephen Hemminger <stephen@networkplumber.org> wrote:

> On Mon, 24 Jun 2013 16:55:00 +0900
> Pawit Pornkitprasan <p.pawit@gmail.com> wrote:
> 
> > [1.] One line summary of the problem:
> > Bridging does not work with Mellanox ConnectX-2 (mlx4_en) card in
> > SR-IOV mode
> 
> For security reasons, SR-IOV cards to not support promiscuous mode
> required for bridging. Also the hardware usually can't do fanout to
> multiple VF's for same unicast packet. --

Stephen, technically you're correct but there is a bit of further
clarification required here.  In the case of Intel adapters that
support SR-IOV we do allow MAC promiscuous mode when the physical
function device is bridged.  This, along with the bridge FDB features
allow for VMs using the SW bridge with virtual interfaces to
communicate with VMs using SR-IOV virtual functions.  However, we leave
the VLAN filtering enabled in the device so that VMs can be isolated
from one another.  So it's not actually promiscuous mode since VLAN
filtering remains enabled, but it does enable promiscuous capture of
MAC addresses.

This feature is something just recently added to Intel adapters to get
around the security problem you mention.

- Greg

> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
