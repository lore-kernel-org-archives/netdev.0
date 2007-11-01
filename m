From: Rick Jones <rick.jones2@hp.com>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Thu, 01 Nov 2007 16:26:01 -0700
Message-ID: <472A6089.7020104@hp.com>
References: <472A49BD.6000802@hp.com>	<20071101.145956.63020380.davem@davemloft.net>	<472A4D5C.2070301@hp.com> <20071101.150723.30590053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: djohnson+linux-kernel@sw.starentnetworks.com,
	greearb@candelatech.com, shemminger@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:45554 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754620AbXKAX0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 19:26:05 -0400
In-Reply-To: <20071101.150723.30590053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
>>I'll try to go pester folks in tcpdump-workers then.
> 
> 
> The thing to check is "TP_STATUS_CSUMNOTREADY".
> 
> When using mmap(), it will be provided in the descriptor.  When using
> recvmsg() it will be provided via a PACKET_AUXDATA control message
> when enabled via the PACKET_AUXDATA socket option.

Figures... the "dailies" and "weeklies" for tar files of tcpdump and libpcap 
source are fubar... again.  I've email in to tcpdump-workers on that one.  If 
that isn't resolved quickly I'll learn how to access their CVS (pick an SCM, any 
SCM...)

I did an apt-get of debian lenny's tcpdump and sources:

hpcpc103:~# tcpdump -V
tcpdump version 3.9.8
libpcap version 0.9.8

and that seems to show the false checksum failure and not use the 
TP_STATUS_CSUMNOTREADY - at least that didn't appear in a grepping of the 
sources.  At first I thought it might be, but then I realized that my snaplen 
was too short to get the whole TSO'ed frame so tcpdump wasn't even trying to 
verify.  After disabling TSO on the NIC, leaving CKO on, and making my snaplen > 
1500 I could see it was doing undesirable stuff.

I'll see what top of trunk has at some point and what the folks there think of 
adding-in a change.

rick jones
