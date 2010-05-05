From: dormando <dormando@rydia.net>
Subject: Re: 3 packet TCP window limit?
Date: Wed, 5 May 2010 14:31:02 -0700 (PDT)
Message-ID: <alpine.LNX.2.00.1005051421010.28957@d>
References: <alpine.LNX.2.00.1005050210230.8544@d> <4BE171EC.20904@athenacr.com> <alpine.LNX.2.00.1005051239290.28957@d> <4BE1D3B0.9000207@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Brian Bloniarz <bmb@athenacr.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([216.218.163.68]:39003 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758666Ab0EEVbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 17:31:04 -0400
In-Reply-To: <4BE1D3B0.9000207@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't believe linux as yet has a damn tunable for it :)

ip route initcwnd sure does it :)

> > Other OS's appear to have a larger initcwnd.
>
> Names?  Values?

OpenBSD 4.6 jumps between a ~5k fetch to a ~6k fetch

> > As do commercial load balancers.
>
> Names?  Values?

An older Big/IP appears to be between 5k and 6k as well. I remember a
sales meeting with netscaler (pre-NDA) back in 2004 or 2005 where they
claimed to have opened up slow start. There might be others but I can't
remember which side of the NDA I was informed of their TCP tunning.

Linux is consistently between 3k and 4k. Just the distinction from having
the RTT in the ~4k or the ~6k range makes our latency graphs go nutty.
I've been testing a subset of traffic at an initcwnd of 10 for the last
few hours and latency has dropped even more, though I see some bad
outliers.

> > The default of 3 seems to be tuned for 56k dialup modems. I'm a
> > little surprised that none of the pluggable TCP congestion control
> > algorithms changed this value. I went through all of them except for
> > tcp_yeah.
>
> The initcwnd comes from IETF RFCs and their "thou shalts" and "thou shalt
> nots."  As you note below, Google et al seek to alter/extend the RFCs.  That
> is an ongoing discussion in some of the ietf related mailing lists.

The RFC clearly states "around 4k", but these other OS's/products have an
extra kilobyte snuck in? Could this be on purpose via rfc
interpretation, or an off by one on the initcwnd estimator? :)
