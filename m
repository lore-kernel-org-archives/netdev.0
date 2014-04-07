From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: (patch needs review) NULL dereference in xfrm_output with NAT
Date: Mon, 7 Apr 2014 12:55:59 +0200
Message-ID: <20140407105559.GO32371@secunet.com>
References: <20140402103711.GJ5945@methuselah>
 <20140404090242.GN32371@secunet.com>
 <20140404122917.GM5945@methuselah>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Martin Pelikan <martin.pelikan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33144 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755159AbaDGK4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2014 06:56:09 -0400
Content-Disposition: inline
In-Reply-To: <20140404122917.GM5945@methuselah>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 04, 2014 at 02:29:17PM +0200, Martin Pelikan wrote:
> 
> Your patch avoids the crash the same way as mine, but doesn't fix my related
> problem: I have two flows through that IPv6 endpoint: IPv6 default gw tunnel
> + IPv4 tunnel between two private networks.  But only one of them works at a
> time, and it is the one which was set up first.
> The other endpoint is OpenBSD with iked(8) and I can see the replies going
> into enc0 there, ESP packets arriving into this Linux box at enp4s6, but the
> traffic isn't being decapsulated and sent further away on br0.
> If I disable the working tunnel (v6 for example), the other one (v4) starts
> working immediately, so it's probably not caused by bad strongSwan config.
> 
> Do you think these bugs might be related?  Any ideas how to proceed without
> spending days on it? 

A good starting point for further debugging would be to find out
where the packets are dropped. xfrm increases a counter whenever
a packet is dropped in the xfrm layer. You can find these counters
in /proc/net/xfrm_stat.
