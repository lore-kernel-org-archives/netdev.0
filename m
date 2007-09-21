From: lepton <ytht.net@gmail.com>
Subject: Re: [PATCH RESEND] 2.6.22.6 networking [ipv4]: fix wrong destination when reply packetes
Date: Fri, 21 Sep 2007 14:03:01 +0800
Message-ID: <20070921060301.GA6019@router.lepton.home>
References: <20070921022335.GA2849@router.lepton.home> <OFC759A0A2.B923AD69-ON8825735D.0017012F-8825735D.00191D21@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lepton <ytht.net@gmail.com>, lkm <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.237]:59643 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbXIUGEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 02:04:09 -0400
Received: by qb-out-0506.google.com with SMTP id e11so554505qbe
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 23:04:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <OFC759A0A2.B923AD69-ON8825735D.0017012F-8825735D.00191D21@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now icmp_reply is only called by icmp_echo and icmp_timestamp
ip_send_reply is only called by tcp_v4_send_reset and tcp_v4_send_ack

I think in all situations the ip_hdr(skb)->saddr is set and should
be the destination of reply packets.

If using rt->rt_src as destination is correct in some situation, 
can anyone give me a example? 

I think perhaps it is a copy and paste from code like
ip_build_and_send_pkt, but reply packets in these situations 
(icmp_echo and icmp_timestamp and tcp_v4_send_ack and tcp_v4_send_reset) 
is diffrent, I think we can just use ip_hdr(skb)->saddr as 
destination address.

On Thu, Sep 20, 2007 at 09:35:09PM -0700, David Stevens wrote:
> I'm not sure why it's using rt_src here, but there are relevant cases that
> your description doesn't cover. For example, what happens if  the source
> is not set in the original packet?  Does NAT affect this?
> 
> You quote RFC text for ICMP echo and the case where the receiving machine
> is the final destination, but you're modifying code that is used for all 
> ICMP
> types and used for ICMP errors generated when acting as an intermediate
> router.
> 
> In ordinary cases, and certainly with ICMP echo when the source is set in
> the original packet and no rewriting is going on (and the address is not 
> spoofed),
> using the original source as the destination is fine. But have you tested 
> or
> considered the other cases?
> 
>                                                 +-DLS
> 
