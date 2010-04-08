From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: dhcp client packet sniffing...
Date: Thu, 08 Apr 2010 16:37:20 +0200
Message-ID: <1270737440.1872.93.camel@sakura.staff.proxad.net>
References: <20100408.035049.177640912.davem@davemloft.net>
	 <20100408114738.GA23329@gondor.apana.org.au>
	 <20100408142722.GA25392@gondor.apana.org.au>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:53378 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755761Ab0DHOha (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Apr 2010 10:37:30 -0400
In-Reply-To: <20100408142722.GA25392@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2010-04-08 at 22:27 +0800, Herbert Xu wrote:

> Oh and if anybody is doing any user-space hacking, this is what you
> could do: AF_PACKET is only necessary when you're waiting for a
> response from the server.  So you could close the socket after a
> lease has been acquired, and reopen it the next time you need
> to communicate with a server.

That's already what some clients do (at least udhcpc from busybox)

The packet socket is only needed during "init_selecting", "init_reboot",
"requesting" and "rebinding" state.

For "bound" or "requesting" state (in which you spend most of the time),
the packet socket is not needed and a standard AF_INET dgram socket can
be used instead.

You can't close the socket while bound since you can receive DHCPINFORM
anytime.

-- 
Maxime


