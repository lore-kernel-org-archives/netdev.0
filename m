From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 14/15] i40e: ignore skb->xmit_more when deciding to
 set RS bit
Date: Mon, 9 Oct 2017 09:07:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD008D373@AcuExch.aculab.com>
References: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
 <20171006175727.868-15-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jacob Keller <jacob.e.keller@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.185]:57808 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751068AbdJIJHi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 05:07:38 -0400
In-Reply-To: <20171006175727.868-15-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher
> Sent: 06 October 2017 18:57
> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> Since commit 6a7fded776a7 ("i40e: Fix RS bit update in Tx path and
> disable force WB workaround") we've tried to "optimize" setting the
> RS bit based around skb->xmit_more. This same logic was refactored
> in commit 1dc8b538795f ("i40e: Reorder logic for coalescing RS bits"),
> but ultimately was not functionally changed.

I've tried to understand the above, but without definitions of WB
and RS and the '4-ness' of something it is quite difficult.

I THINK this is all about telling the hardware there is a packet
in the ring to transmit?

I don't understand the 4-ness. Linux requires that the hardware
be notified of a single packet transmit, and that the 'transmit
complete' also be notified in 'a timely manner' for a single packet.

skb->xmit_more ought to be usable to optimise both of these
(assuming it isn't a lie).
The driver would need to ensure a ring full of messages isn't
generated without either wakeup - but that might be 128 frames.

FWIW on the systems I have PCIe writes are relatively cheap
(reads are slow). So different counts would be appropriate
for delaying doorbell writes and requesting completion interrupts.

	David
