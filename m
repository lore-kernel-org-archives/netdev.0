From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to submit
	to upper layer
Date: Fri, 13 Mar 2009 14:59:55 -0700
Message-ID: <65634d660903131459m645eb468y3ad850a1fd56d447@mail.gmail.com>
References: <65634d660903131006n44f068dw18b2fe9dce25399e@mail.gmail.com>
	 <20090313.115137.254924980.davem@davemloft.net>
	 <65634d660903131358h765bef64y6a0f1b0db7400f6f@mail.gmail.com>
	 <20090313.140217.143696945.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yanmin_zhang@linux.intel.com, bhutchings@solarflare.com,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	jesse.brandeburg@intel.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:46574 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755634AbZCMWAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 18:00:00 -0400
In-Reply-To: <20090313.140217.143696945.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> If the hash is good is will distribute the load properly.
>
> If the NIC is sophisticated enough (Sun's Neptune chipset is)
> you can even group interrupt distribution by traffic type
> and even bind specific ports to interrupt groups.
>
> I really detest all of these software hacks that add overhead
> to solve problems the hardware can solve for us.
>

I appreciate this philosophy, but unfortunately I don't have the
luxury of working with a NIC that solves these problems.  The reality
may be that we're trying to squeeze performance out of crappy hardware
to scale on multi-core.  Left alone we couldn't get the stack to
scale, but with these "destable hacks" we've gotten 3X or so
improvement in packets per second across both our dumb 1G and 10G
NICs.  These gains have translated into tangible application
performance gains, so we'll probably continue to have interest in this
area of development at least for the foreseeable future.
