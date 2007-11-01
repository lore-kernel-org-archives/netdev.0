From: Rick Jones <rick.jones2@hp.com>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Thu, 01 Nov 2007 14:48:45 -0700
Message-ID: <472A49BD.6000802@hp.com>
References: <20071031123359.3954befc@freepuppy.rosehill>	<4729269A.6090606@candelatech.com>	<47292A99.5070805@linux-foundation.org>	<20071031.215025.195350296.davem@davemloft.net>	<4729EAFF.9050606@candelatech.com> <18218.18134.353553.189622@zeus.sw.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:32882 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754054AbXKAVuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 17:50:05 -0400
In-Reply-To: <18218.18134.353553.189622@zeus.sw.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>The code in AF_PACKET should fix the skb before passing to user
>>space so that there is no difference between accel and non-accel
>>hardware.  Internal choices shouldn't leak to user space.  Ditto,
>>the receive checksum offload should be fixed up as well.
> 
> 
> yep.  bad csum on tx packets as reported by tcpdump is also an issue.

With TX CKO enabled, there isn't any checksum to fixup when a tx packet is 
sniffed, so I'm not sure what can be done in the kernel apart from an 
unpalatable "disable CKO and all which depend upon it when entering promiscuous 
mode."  Having the tap calculate a checksum would be equally bad for 
performance, and would frankly be incorrect anyway because it would give the 
user the false impression that was the checksum which went-out onto the wire.

One could I suppose try to ammend the information passed to allow tcpdump to say 
"oh, this was a tx packet on the same machine on which I am tracing so don't 
worry about checksum mismatch" but I have to wonder if it is _really_ worth it. 
Already someone has to deal with seeing TCP segments >> the MSS thanks to TSO. 
(Actually tcpdump got rather confused about that too since the IP length of 
those was 0, but IIRC we got that patched to use the length of zero as a "ah, 
this was TSO so wing it" heuristic.)

rick jones
