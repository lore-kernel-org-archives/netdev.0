From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: 2.6.32 and Multicast group membership
Date: Sat, 5 Jun 2010 21:03:58 +0930
Message-ID: <20100605210358.06e703df@lk-netdev.nosense.org>
References: <4C057DF4.3000305@exegy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Net Dev <netdev@vger.kernel.org>
To: "Mr. Berkley Shands" <bshands@exegy.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.adam.net.au ([202.136.110.251]:51675 "EHLO
	smtp2.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940Ab0FELdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 07:33:20 -0400
In-Reply-To: <4C057DF4.3000305@exegy.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 Jun 2010 16:39:00 -0500
"Mr. Berkley Shands" <bshands@exegy.com> wrote:

> starting in 2.6.32, my multicast connections stop getting data after 
> 60-100 seconds.
> The identical user code works fine under 2.6.22 through 2.6.31.
> 
> The NIC (an intel 82586) has two ports on the same subnet
> (eth0 at 172.16.21.55/24 and eth1 at 172.16.21.56/24)
> 
>       if (setsockopt(sock, IPPROTO_IP, IP_ADD_MEMBERSHIP, (char*)&req, 
> sizeof(req)))
>       {
>          perror("setsockopt IP_ADD_MEMBERSHIP failed");
>          ::exit(-1);
>       }
> 
> If I do ADD_MEMBERSHIP on just one of these interfaces, the sockets 
> still get data.
> But if I join on both interfaces, one or both will stop getting packets
> after 60-100 seconds. Sniffing with tcpdump shows the Cisco layer 3 switch
> is not getting its responses back to keep the multicast group open.

While it could be a kernel change, that sounds like it might also be
related to IGMP snooping on the Cisco switch. Any changes made to that
recently?

> The HP layer 2 switch does not seem to care, it keeps the data flowing 
> regardless
> of which physical port the join is executed on.
> 

This is expected behaviour on a 'dumb' layer 2 switch i.e. one that
doesn't perform IGMP snooping and therefore doesn't suppress multicasts
towards end-nodes that aren't subscribed. That further suggests a
change on the Cisco.

FWIW, I'm having no trouble with IPv4 multicast under 2.6.33, plugged
into Cisco switch, with IGMP snooping, but not multicast suppression,
enabled.

> Changing IP_MULTICAST_ALL has no effect :-(
> Did I miss something? New code that I have to specify to keep the Cisco 
> happy?
> 
> tia
> 
> Berkley
> 
> 
> -- 
> 
> // E. F. Berkley Shands, MSc//
> 
> ** Exegy Inc.**
> 
> 349 Marshall Road, Suite 100
> 
> St. Louis , MO  63119
> 
> Direct:  (314) 218-3600 X450
> 
> Cell:  (314) 303-2546
> 
> Office:  (314) 218-3600
> 
> Fax:  (314) 218-3601
> 
>  
> 
> The Usual Disclaimer follows...
> 
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
