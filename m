From: David Miller <davem@davemloft.net>
Subject: Re: vpnc-script fix for changed iproute output with newer kernels
Date: Fri, 29 Jul 2011 05:46:49 -0700 (PDT)
Message-ID: <20110729.054649.1274733167127164255.davem@davemloft.net>
References: <20110728021227.GA3620@gmail.com>
	<20110728021853.GB3620@gmail.com>
	<1311942793.17528.57.camel@i7.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jsbronder@gentoo.org, netdev@vger.kernel.org, shemminger@vyatta.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755617Ab1G2MsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 08:48:09 -0400
In-Reply-To: <1311942793.17528.57.camel@i7.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Fri, 29 Jul 2011 13:33:11 +0100

> Any suggestions that *aren't* going to be constantly broken?

You're going to have to be knowledgable about which attributes are
part of the route, whether you want to do this with iproute2 as a tool
or whether you do this directly with C code using netlink.

If you want to script this using iproute2, you should be grepping for
the attributes you want to keep rather then grepping for the
attributes you end up dropping.

iproute2 is never going to allow you to mirror "route get" outputs
into a "route add" call.  Because 'get' is going to always emit
metrics and other transient state, upon which we will always
potentially be buidling new items over time.
