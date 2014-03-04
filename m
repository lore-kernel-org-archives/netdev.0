From: Andy Lutomirski <luto@amacapital.net>
Subject: TX timestamping for ICMP (sfc and core)?
Date: Tue, 4 Mar 2014 12:43:34 -0800
Message-ID: <CALCETrXpaD4i9V2Qv_0xfouGRb_y27-R6fOQ5v4Q97jNwgecFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Network Development <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f181.google.com ([209.85.220.181]:50977 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932355AbaCDUnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 15:43:55 -0500
Received: by mail-vc0-f181.google.com with SMTP id lg15so66338vcb.40
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 12:43:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to get tx timestamping working on ping sockets.  My program
works fine (with hardware TX timestamps) if I send my "pings" on the
PTP UDP ports.  I want to send real ICMP pings, though.

It looks like there are two problems:

 - Something in the core code seems to eat SKBTX_HW_STAMP on ping
sockets.  At least, this code in efx_hard_start_xmit triggers for
IPPROTO_UDP on PTP ports but not for IPPROTO_ICMP:

        if (unlikely(efx_xmit_with_hwtstamp(skb)))
                printk(KERN_DEBUG "sfc: trying to do a TX timestamp\n");

 - The sfc driver refuses to timestamp non-PTP packets.  There's a
check in efx_hard_start_xmit and another in ptp.c.  I suspect that the
hardware can support timestamping any outgoing packet, but I'm not
really sure.  (I'm using an SFN7322F.)

Thanks,
Andy
