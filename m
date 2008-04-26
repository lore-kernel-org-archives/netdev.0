From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Fri, 25 Apr 2008 23:31:31 -0700 (PDT)
Message-ID: <20080425.233131.247778262.davem@davemloft.net>
References: <20080425.230116.234973563.davem@davemloft.net>
	<OF87A40341.D5C4561E-ON88257437.002279E3-88257437.00234E0B@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751769AbYDZGbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 02:31:31 -0400
In-Reply-To: <OF87A40341.D5C4561E-ON88257437.002279E3-88257437.00234E0B@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Fri, 25 Apr 2008 23:25:39 -0700

> I considered passing the the real setsockopt function as an argument
> to what is now compat_mc_setsockopt() before putting the direct calls in.
> By doing that, we can only get in there with a v6 setsockopt when v6 is
> loaded, since the calls to it are from the corresponding 
> compat_setsockopt.
> Is that too ugly?
> 
>         Could also make these  return pointers to the new koptval and 
> koptlen,
> which is really the only thing we need outside the 
> compat_ipXX_setsockopt()'s.

If you're going to use callbacks, and I'd be also asking you to
guard this code with CONFIG_IPV6 as appropriate, why not simply
put it into the ipv6 socket option handling code?

I really see no value putting this in some generic location
if we have to deal with those issues, by adding callbacks and
ifdef'ery.
