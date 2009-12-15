From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH 1/4] net: port mirroring: add tracepoints to
	appropriate network paths
Date: Tue, 15 Dec 2009 12:02:49 -0500
Message-ID: <20091215170249.GB20644@hmsreliant.think-freely.org>
References: <20091215162956.GB18710@hmsreliant.think-freely.org> <20091215163604.GC18710@hmsreliant.think-freely.org> <20091215084424.291459cb@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47051 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461AbZLORCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 12:02:52 -0500
Content-Disposition: inline
In-Reply-To: <20091215084424.291459cb@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 15, 2009 at 08:44:24AM -0800, Stephen Hemminger wrote:
> On Tue, 15 Dec 2009 11:36:04 -0500
> Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > Add net_dev_xmit & net_dev_receive tracepoints
> > 
> > Add tracepoints at the end of the network stack xmit path and the start of the
> > stack receive path.  Among other uses, these tracepoints can be used to tap the
> > raw input and output streams for any given network device for the purposes of
> > mirroring that traffic to other ports.
> > 
> 
> There already is a mirroring solution but people don't know how to use it.
> Using mirred on ingress qdisc does that.
> 
I wish that had been easier to find.  That only appears to mirror inbound frames
though, what about outbound frames? can you attach mirred to an outbound qdisc?

> Why would we want to add another hook to the already complex networking
> code path?
> 
Because tracepoints offer a low/zero impact hook (when not in use) that is
extensible to future debug needs.  Given that mirroring is largely a feature to
enable debugging, I thought tracepoints appropriate.

> https://svn.openfabrics.org/svn/openib/gen2/branches/1.1/src/userspace/ipoibtools/iproute2/doc/actions/mirred-usage
Reading over this, I'm still left wondering if this ony mirrors inbound frames.
Is the expectation that outbound frames can be mirrored using some other method?
Or can you just attach this tc action to an outbound qdisc?

Regards
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
