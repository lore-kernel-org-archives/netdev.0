From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit kernels.
Date: Fri, 25 Apr 2008 23:25:39 -0700
Message-ID: <OF87A40341.D5C4561E-ON88257437.002279E3-88257437.00234E0B@us.ibm.com>
References: <20080425.230116.234973563.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:37980 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbYDZGZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 02:25:44 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3Q6PirK007223
	for <netdev@vger.kernel.org>; Sat, 26 Apr 2008 02:25:44 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3Q6PhjJ187344
	for <netdev@vger.kernel.org>; Sat, 26 Apr 2008 00:25:43 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3Q6Ph5s002554
	for <netdev@vger.kernel.org>; Sat, 26 Apr 2008 00:25:43 -0600
In-Reply-To: <20080425.230116.234973563.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, what about this:

I considered passing the the real setsockopt function as an argument
to what is now compat_mc_setsockopt() before putting the direct calls in.
By doing that, we can only get in there with a v6 setsockopt when v6 is
loaded, since the calls to it are from the corresponding 
compat_setsockopt.
Is that too ugly?

        Could also make these  return pointers to the new koptval and 
koptlen,
which is really the only thing we need outside the 
compat_ipXX_setsockopt()'s.

                                                +-DLS

