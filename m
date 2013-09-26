From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Established sockets remain open after iface down or address lost
Date: Thu, 26 Sep 2013 06:49:43 -0700
Message-ID: <1380203383.3165.172.camel@edumazet-glaptop>
References: <20130926060433.GA9170@cverges-dev-lnx.sentient-energy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: Chris Verges <cverges@sentient-energy.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:46791 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773Ab3IZNto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 09:49:44 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so1183273pdj.4
        for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 06:49:44 -0700 (PDT)
In-Reply-To: <20130926060433.GA9170@cverges-dev-lnx.sentient-energy.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-25 at 23:04 -0700, Chris Verges wrote:
> Hello all,
> 
> I've encountered a behavior that appears to be known, but am seeking
> some clarity on its rationale.  The scenario is as follows:
> 
>   (0) A TCP server socket listens on :: (v4/v6).
>   (1) Connect a USB/Ethernet adapter to a Linux system.
>   (2) Adapter is brought up as 'eth0' with an IP address.
>   (3) A remote TCP client connects to the server socket.
>   (4) 'netstat -anp' shows the socket as ESTABLISHED
>   (5) The TCP server starts a blocking read waiting for data.
>   (6) Physically disconnect the USB/Ethernet adapter from the USB bus.
>   (7) Linux removes the 'eth0' interface and associated IP address.
> 
> At this point, the socket _still_ shows as ESTABLISHED under netstat.
> 
> This is the paradox.  Why is the blocking read not interrupted with a
> socket error to indicate that the socket is no longer viable?

Because TCP layer is not sensitive to such temporary events.

You can plug again your iface, and IP is valid again.

Why should we give a permanent error for such case ?

If network communication is cut somewhere, TCP is not supposed to
immediately react. Normal timeouts and retransmits take place. 
