From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit kernels.
Date: Sat, 26 Apr 2008 00:13:34 -0700
Message-ID: <OF9BF48C5B.EB7BA30D-ON88257437.00269450-88257437.0027B15D@us.ibm.com>
References: <20080425.233131.247778262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:48680 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbYDZHNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 03:13:38 -0400
In-Reply-To: <20080425.233131.247778262.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If you're going to use callbacks, and I'd be also asking you to
> guard this code with CONFIG_IPV6 as appropriate, why not simply
> put it into the ipv6 socket option handling code?

        Well, I didn't want to make 2 copies of completely identical
code and then just change the protocol setsockopt code we call at
the end of it. If we did this:

compat_ipv6_setsockopt()
{
        if (got an MCAST* optval)
                return compat_mc_setsockopt(....optval, optlen, 
ipv6_setsockopt);
}

and in compat_mc_setsockopt:

int compat_mc_setsockopt(...., func decl) {
        ...all common code that twiddles args for both IPv6 and IPv4
        return func(....);
}

        Then there are no cross references to anything else in the
compat code and we can't get there with func==ipv6_setsockopt unless
we were called from compat_ipv6_setsockopt(), which means we must have
ipv6_setsockopt(). Right? The protocol setsockopt functions are already
external, so I'd expect compat would need any CONFIG guarding. Am I
missing something?

                                                        +-DLS

