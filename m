From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: vpnc-script fix for changed iproute output with newer kernels
Date: Fri, 29 Jul 2011 13:57:03 +0100
Message-ID: <1311944244.17528.76.camel@i7.infradead.org>
References: <20110728021227.GA3620@gmail.com>
	 <20110728021853.GB3620@gmail.com>
	 <1311942793.17528.57.camel@i7.infradead.org>
	 <20110729.054649.1274733167127164255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jsbronder@gentoo.org, netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37376 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755975Ab1G2M52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 08:57:28 -0400
In-Reply-To: <20110729.054649.1274733167127164255.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-07-29 at 05:46 -0700, David Miller wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Fri, 29 Jul 2011 13:33:11 +0100
> 
> > Any suggestions that *aren't* going to be constantly broken?
> 
> You're going to have to be knowledgable about which attributes are
> part of the route, whether you want to do this with iproute2 as a tool
> or whether you do this directly with C code using netlink.

I don't think I really want to try shipping vpnc-script with C code.

The 'opt-in' approach seems like the best one for now, then. I suppose
we want just the 'via' and 'dev' and 'src' attributes... anything else?

I'll see if I can come up with a regex that can parse that, in the
knowledge that the interface itself might actually be called "src" or
"dev" or "via".

This may make my brain hurt.

> iproute2 is never going to allow you to mirror "route get" outputs
> into a "route add" call.  Because 'get' is going to always emit
> metrics and other transient state, upon which we will always
> potentially be buidling new items over time.

An option to make 'ip route get' do exactly that would be massively
appreciated :)

Or an option to make 'ip route set' ignore the ones it doesn't like,
perhaps.

-- 
dwmw2

