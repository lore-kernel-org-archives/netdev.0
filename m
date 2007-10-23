From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH RESEND] ip_gre: sendto/recvfrom NBMA address
Date: Tue, 23 Oct 2007 23:03:24 +0400
Message-ID: <20071023190324.GA1267@ms2.inr.ac.ru>
References: <471E05BD.7040407@iki.fi> <471E0638.9040405@trash.net> <471E19E5.5040509@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Timo Ter?s <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:35664 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752209AbXJWTEK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 15:04:10 -0400
Content-Disposition: inline
In-Reply-To: <471E19E5.5040509@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> When GRE tunnel is in NBMA mode, this patch allows an application to use
> a PF_PACKET socket to:
> - send a packet to specific NBMA address with sendto()
> - use recvfrom() to receive packet and check which NBMA address it came from
> 
> This is required to implement properly NHRP over GRE tunnel.

Ack. This is good idea.

Frankly, I was sure ip_gre worked in this way all these years.
I do not remember any reasons why it was crippled.

The only dubious case is when next hop is set using routing tables.
But code in ipgre_tunnel_xmit() is ready to accept this situation,
it checks for zero destination address and fixes it when it is able to.

Alexey
