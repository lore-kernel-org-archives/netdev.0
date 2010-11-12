From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [RFC PATCH] network: return errors if we know tcp_connect failed
Date: Fri, 12 Nov 2010 20:46:20 +0300
Message-ID: <20101112174620.GA16544@ms2.inr.ac.ru>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:43331 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755400Ab0KLRql (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Nov 2010 12:46:41 -0500
Content-Disposition: inline
In-Reply-To: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Thu, Nov 11, 2010 at 04:03:41PM -0500, Eric Paris wrote:
> immediately when it calls connect().  Is this wrong?  Is this bad to tell
> userspace more quickly what happened?  Does passing this error code back up
> the stack here break something else?  Why do some functions seem to pay
> attention to tcp_transmit_skb() return codes and some functions just ignore
> it?

Essentially, return value of tcp_transmit_skb() is always ignored.
It is used only for accounting and for some optimization of retransmission behaviour.
Generally, tcp does not react on errors coming outside of tcp protocol.

The only loophole is ICMP error in the same case as yours. In _violation_ of specs
linux immediately aborts unestablished connect on an icmp error. IMHO that thing
which you suggest is correct (of course, provided you filter out transient errors and react only
to EPERM or something like this). It was not done because it was expected
firewall rule prescribing immediate abort is configured with "--reject-with icmp-port-unreachable",
otherwise the rule orders real blackhole.

Alexey
