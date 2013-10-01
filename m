From: Chris Verges <cverges@sentient-energy.com>
Subject: Re: Established sockets remain open after iface down or address lost
Date: Tue, 1 Oct 2013 09:08:25 -0700
Message-ID: <20131001160825.GA8784@cverges-dev-lnx.sentient-energy.com>
References: <20130926060433.GA9170@cverges-dev-lnx.sentient-energy.com>
 <1380203383.3165.172.camel@edumazet-glaptop>
 <20131001132707.GA7442@cverges-dev-lnx.sentient-energy.com>
 <524AEDD1.9010709@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:34873 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704Ab3JAQI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:08:29 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc17so7330067pbc.18
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 09:08:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <524AEDD1.9010709@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 01, 2013 at 08:44:17AM -0700, Rick Jones wrote:
> The protocol between client and server needs to have an
> application-layer "keepalive" mechanism added, and then the server
> will be able to detect a dangling connection without need of any
> further kernel modifications.
> 
> If that is not possible, the server can/should set SO_KEEPALIVE and
> perhaps tweak the TCP keepalive settings.  Not as good (IMO) as an
> application-layer keepalive because it only shows that the connection
> is good as far as TCP, but I suppose it could do in a pinch.

I agree that some form of keepalives would solve the problem where
blocking reads need to be interrupted.  However, this creates traffic
across the link -- directly proportional to the keepalive interval.

The underlying physical layer is such that we pay for all traffic going
across it -- including any keepalives at either the application or TCP
layers.  Paying for this keepalive traffic when the link is operational
is not desired.

Thanks for the suggestion.  I, too, am hoping that a kernel mod isn't
required to do what is being asked.  But I'm also willing to put in the
work if needed.  My hope on engaging with the netdev list early in this
process is to (1) figure out whether this has already been fully solved
and (2) determine whether there would be interest in this patch for
general use.

Thanks,
Chris
