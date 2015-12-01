From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 30 Nov 2015 22:48:43 -0500 (EST)
Message-ID: <20151130.224843.112081502554527779.davem@davemloft.net>
References: <CALx6S36vQhx+iKP9VcpqPBnN7VjBsgd_dYFOfZ+YHyVa97-ajA@mail.gmail.com>
	<20151129.222243.2290113258075462913.davem@davemloft.net>
	<C40BE8378EF49C44B9184714DBC8EF2993A70447@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, jesse.brandeburg@intel.com, jesse@kernel.org,
	netdev@vger.kernel.org, kiran.patil@intel.com
To: anjali.singhai@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733AbbLADsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 22:48:47 -0500
In-Reply-To: <C40BE8378EF49C44B9184714DBC8EF2993A70447@ORSMSX115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Singhai, Anjali" <anjali.singhai@intel.com>
Date: Mon, 30 Nov 2015 21:42:37 +0000

> The reason for receive being different than transmit is, on TX side
> driver can provide the meta data for where the checksum field is and
> what is the length that needs to be check summed to the HW on a per
> packet basis. On Rx the HW parser has to parse the packet to
> identify the tunnel type and based on that figure out the checksum
> locations and length in the packet, so definitely HW has to parse
> the packet and it can parse only based on next header type
> information or in case of udp tunnels based on udp port mapping to a
> particular protocol. I am not sure why you say it doesn't need to
> parse the packet, maybe I am miss- understanding something.
> Although it's not difficult to reduce protocol ossification on the
> RX side but it is certainly different and particularly in case of
> udp-tunnels it needs the port to protocol mapping.

You're just proving more and more why doing anything other than 2's
complement checksum provision in the RX descriptor is stupid.

Let me know when you guys enter this century.

I'll tell you right now that your arguments are akin to trying to
climb up a wall which is vertical.  I can assure you that you will not
reach your destination, so save your self some scratching and clawing
and accept reality.

Doing anything other than providing 2's complement checksums in the RX
descriptor doesn't work.  We know this.

So we will not add to our core architecture and frameworks anything
that directly facilitates designs which we know are suboptimal.  And
protocol specific support for tunnel offloading is suboptimal and not
the way forward.

I completly agree with Tom, his goals, his vision, and his priorities
when it comes to handling this stuff.  Don't fight it.

You also need to learn how to properly reply to list postings, it
looks terrible, as if you're replying to Tom then adding in my comment
which is what you are actually repling to.
