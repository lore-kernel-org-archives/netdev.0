From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] network: return errors if we know tcp_connect
 failed
Date: Fri, 12 Nov 2010 11:28:36 -0800 (PST)
Message-ID: <20101112.112836.183042210.davem@davemloft.net>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com>
	<20101112174620.GA16544@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54549
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756825Ab0KLT2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 14:28:11 -0500
In-Reply-To: <20101112174620.GA16544@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Fri, 12 Nov 2010 20:46:20 +0300

> The only loophole is ICMP error in the same case as yours. In
> _violation_ of specs linux immediately aborts unestablished connect
> on an icmp error. IMHO that thing which you suggest is correct (of
> course, provided you filter out transient errors and react only to
> EPERM or something like this). It was not done because it was
> expected firewall rule prescribing immediate abort is configured
> with "--reject-with icmp-port-unreachable", otherwise the rule
> orders real blackhole.

The idea to signal on -EPERM might be OK, but if that's also
what things like "-m statistical" and friends end up reporting
then we still cannot do it.
