From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Add sysctl knob to control early socket demux
Date: Sat, 23 Jun 2012 07:45:26 +0200
Message-ID: <1340430326.4604.11946.camel@edumazet-glaptop>
References: <20120621235011.29846.29715.stgit@gitlad.jf.intel.com>
	 <20120622.171509.1112294083000632011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:38940 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167Ab2FWFpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 01:45:33 -0400
Received: by wgbdr13 with SMTP id dr13so2402812wgb.1
        for <netdev@vger.kernel.org>; Fri, 22 Jun 2012 22:45:32 -0700 (PDT)
In-Reply-To: <20120622.171509.1112294083000632011.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-22 at 17:15 -0700, David Miller wrote:

> I applied this for now, making a minor change to move the local
> variables down into the new basic block you created.
> 

Hmm, sorry to come late, but you left NET_IPV4_EARLY_DEMUX=126 sysctl,
while this is deprecated way...

> There has got to be a way to make this really cheap.  At the very
> least we can have the GRO code store away the ports and therefore
> allow us to just do a direct call to try and demux the socket.  Thus,
> we'd avoid all of pskb_may_pull() et al. packet validations, and
> packet header pointer calculations.
> 
> Furthermore, we can reduce to overhead by making a special inet
> established hash demux that doesn't check for time-wait sockets,
> reducing the number of probes to 1 from 2.

The timewait hash chain is on the same cache line than established one.
And on a router, both chains are empty with a 99.999 % probability.
