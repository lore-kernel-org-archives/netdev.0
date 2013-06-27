From: Roman Mamedov <rm@romanrm.ru>
Subject: Re: [PATCH RESEND] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Thu, 27 Jun 2013 13:49:59 +0000 (UTC)
Message-ID: <loom.20130627T154125-104@post.gmane.org>
References: <20130123100248.GB7317@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:45748 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933Ab3F0NzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 09:55:06 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UsCf9-0004lE-Qy
	for netdev@vger.kernel.org; Thu, 27 Jun 2013 15:55:03 +0200
Received: from 5.45.183.23 ([5.45.183.23])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 27 Jun 2013 15:55:03 +0200
Received: from rm by 5.45.183.23 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 27 Jun 2013 15:55:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes <at> stressinduktion.org> writes:

> 
> This patch adds anti-spoofing checks in sit.c as specified in RFC3964
> section 5.2 for 6to4 and RFC5969 section 12 for 6rd. I left out the
> checks which could easily be implemented with netfilter.
> 
> Specifically this patch adds following logic (based loosely on the
> pseudocode in RFC3964 section 5.2):
> 
> if prefix (inner_src_v6) == rd6_prefix (2002::/16 is the default)
>         and outer_src_v4 != embedded_ipv4 (inner_src_v6)
>                 drop
> if prefix (inner_dst_v6) == rd6_prefix (or 2002::/16 is the default)
>         and outer_dst_v4 != embedded_ipv4 (inner_dst_v6)
>                 drop
> accept
> 
> To accomplish the specified security checks proposed by above RFCs,
> it is still necessary to employ uRPF filters with netfilter. These new
> checks only kick in if the employed addresses are within the 2002::/16 or
> another range specified by the 6rd-prefix (which defaults to 2002::/16).

Hello,

This broke access to all 6to4 destinations from any unrelated sit tunnels.

For example users of tunnelbroker.net IPv6 tunnel service (2001:470::/32)
can no longer communicate with anyone using 6to4 anywhere on the internet.

In general, any host, routing to/from which happens to traverse a sit
tunnel (using native IPv6 ranges), can no longer successfully send
packets to a 6to4 destination.

Thanks
