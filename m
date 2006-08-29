From: Olaf Kirch <okir@suse.de>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 13:10:54 +0200
Message-ID: <20060829111053.GL1201@suse.de>
References: <20060829082435.GA2676@suse.de> <20060829.183426.52410264.yoshfuji@linux-ipv6.org> <20060829.025400.37356422.davem@davemloft.net> <Pine.LNX.4.64.0608291348520.25442@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, jbeulich@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:23694 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932304AbWH2LLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 07:11:04 -0400
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0608291348520.25442@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2006 at 01:55:28PM +0300, Pekka Savola wrote:
> It's not obvious that IFF_MULTICAST is good enough.  IMHO, you should 
> be able to run addrconf on non-multicast interfaces as well (e.g., 
> point-to-point interfaces, tunnels in particular).

So would it work to use this?
	(flags & (IFF_MULTICAST|IFF_POINTOPOINT)) == 0

> It seems that current code already excludes IFF_NOARP interfaces 
> though.

I looked at that - it doesn't help because it just disables DAD, but
still does router solicitation, and I think it also sends a MLD listener
report with the bogus link-layer address. I tend to agree that it's
incorrect to assign an address at all in this case.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
