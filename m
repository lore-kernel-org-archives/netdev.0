From: "Gerd v. Egidy" <lists@egidy.de>
Subject: Re: xfrm by MARK: tcp problems when mark for in and out differ
Date: Thu, 14 Oct 2010 15:01:59 +0200
Message-ID: <201010141501.59145.lists@egidy.de>
References: <201010131557.06588.lists@egidy.de> <1287057741.3756.6.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs02.intra2net.com ([81.169.173.116]:46394 "EHLO
	rs02.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010Ab0JNNCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 09:02:04 -0400
In-Reply-To: <1287057741.3756.6.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

> > -> incoming packets are without mark, outgoing packets are marked with 5
> 
> You could use tc ingress path to mark incoming packets. Example:

In my full setup I do exactly that. What I posted was a minimized setup to 
just show the problem.

I have a complex set of netfilter rules and routing tables to allow several 
ways of doing NAT on ipsec. The rules need different marks on packets coming 
from / going to the vpn to correctly distinguish packets in the forwarding 
case.

I did further testing, 2.6.36-rc7 has the problem too.

> When the SYN-ACK hits __xfrm_lookup, the value in fl->mark is 0 
> (more precisely: the mark value used in the incoming packet).

this is wrong, the value in fl->mark is always 0. I must have confused some 
data in my debug printks.

So it seems like the fl->mark is never initialized with the packet mark in the 
first place. What would be the correct stage in the kernel network stack to do 
that?

Kind regards,

Gerd

-- 
Address (better: trap) for people I really don't want to get mail from:
jonas@cactusamerica.com
