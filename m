From: Patrick McHardy <kaber@trash.net>
Subject: Re: question on netlink_overrun()
Date: Thu, 05 Mar 2009 06:56:02 +0100
Message-ID: <49AF6972.8000103@trash.net>
References: <49AF2871.10804@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58224 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbZCEF4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 00:56:05 -0500
In-Reply-To: <49AF2871.10804@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen wrote:
> Currently we set netlink_overrun() on the socket in both the unicast and 
> broadcast paths.  If I understand things correctly this should result in 
> the receiver getting ENOBUFS the next time they try a socket-related 
> syscall.
> 
> However, in the netlink_dump() code we don't call it--was this an 
> oversight or an intentional design decision?
> 
> I have a userspace app that would like to know if it ran out of buffer 
> space in the receive socket (and hence lost some packets) while dumping 
> SA information in xfrm_user_rcv_msg().

The dump should never overrun since it has flow control based
on available socket memory. Once the decision has been made
to send a dump packet and it has been sucessfully allocated,
it is never dropped. Except when explicitly filtered.
