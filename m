From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] Rate should be u64 to avoid integer overflow at high
 speeds (>= ~35Gbit)
Date: Tue, 12 Mar 2013 15:42:45 +0000
Message-ID: <20130312154245.GA13101@casper.infradead.org>
References: <1362885604-14006-1-git-send-email-j.vimal@gmail.com>
 <1362888229.4051.2.camel@edumazet-glaptop>
 <CAK3Ji11Mij3Y_sGC6nLS01rxfccZo0SPJmQy-LAmskz1OEdmkQ@mail.gmail.com>
 <1362891937.4051.25.camel@edumazet-glaptop>
 <20130310004904.de508bfa.billfink@mindspring.com>
 <1362894876.4051.27.camel@edumazet-glaptop>
 <513F3BE1.2080409@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Bill Fink <billfink@mindspring.com>, Vimal <j.vimal@gmail.com>,
	netdev@vger.kernel.org, shemminger <shemminger@vyatta.com>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56830 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933065Ab3CLPmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 11:42:53 -0400
Content-Disposition: inline
In-Reply-To: <513F3BE1.2080409@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/13 at 08:29am, Chris Friesen wrote:
> The only problem I see is that you can't set the multiplier with a
> new tool and then query the rate with old tools.
> 
> But you're going to run into that problem with the old tools no
> matter what you do--and not doing anything is a crappy option as
> well.
> 
> Some kind of multiplier or shift makes as much sense as anything
> else. With old tools you get current behaviour, with new tools you
> can specify a multiplying factor to trade off resolution vs
> precision.

The introduction of a shift operator or multiplier introduces
inprecision. I'd much rather see new 64bit Netlink attributes
that, if present, replace the old rate values and statistics.

You will need to add a new Netlink attribute anyway and we might
as well transfer the actual rate instead of a multiplier. Just
like we did with IFLA_STATS64.
