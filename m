From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] iproute2: support dotted-quad netmask notation.
Date: Thu, 6 Dec 2007 11:53:50 -0800
Message-ID: <20071206115350.18e9204f@freepuppy.rosehill>
References: <20071204135818.GA24419@scream.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51532 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751487AbXLFTy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 14:54:58 -0500
In-Reply-To: <20071204135818.GA24419@scream.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Dec 2007 14:58:18 +0100
Andreas Henriksson <andreas@fatal.se> wrote:

> Suggested patch for allowing netmask to be specified in dotted quad format.
> See http://bugs.debian.org/357172
> 
> (Known problem: this will not prevent some invalid syntaxes,
> ie. "255.0.255.0" will be treated as "255.255.255.0")
> 
> Comments? Suggestions? Improvements?

Fix the bug you mentioned?

/* a valid netmask must be 2^n - 1 (n = 1..31) */
static int is_valid_netmask(const inet_prefix *addr)
{
	uint32_t host;

	if (addr->family != AF_INET)
		return 0;

	host = ~ntohl(addr->data[0]);
	if (host == 0 || ~host == 0)
		return 0;

	return (host & (host + 1)) == 0;
}
