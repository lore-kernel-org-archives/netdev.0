From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCHv2 net] net: restore lro after device detached from bridge
Date: Mon, 2 Feb 2015 12:15:56 +0100
Message-ID: <20150202111556.GA8655@unicorn.suse.cz>
References: <1422621209-23222-1-git-send-email-fan.du@intel.com>
 <54CBEE24.8000603@redhat.com>
 <54CEDEDC.7060507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Fan Du <fan.du@intel.com>, bhutchings@solarflare.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45006 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752463AbbBBLP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2015 06:15:59 -0500
Content-Disposition: inline
In-Reply-To: <54CEDEDC.7060507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 02, 2015 at 10:20:12AM +0800, Fan Du wrote:
> 
> I think you are talking about bad scenarios when net device is
> attached to a bridge.  Then what's the good reason user has to pay
> extra cpu power for using GRO, instead of using hw capable LRO/RSC
> when this net device is detached from bridge acting as a standalone
> NIC?

Being bridged is only one of the situations when LRO needs to be
disabled. Does your patch make sure it doesn't enable LRO if there are
other reasons for it to be disabled, e.g. if forwarding is enabled for
it or any of its upper devices?

I'm afraid the only way to make the automatic reenabling work correctly
would be to keep track if LRO was disabled manually (e.g. by ethtool) or
only automatically because the device is bridged, forwarding is enabled
for it, LRO is disabled for any upper device etc. And to reenable LRO
only in the second case and even then only if none of the possible
reasons holds. I don't think it's worth the effort.

> Note, SRC is defaulted to *ON* in practice for ALL ixgbe NICs, as same
> other RSC capable NICs.

A very bad idea, IMHO. A lot of bug reports resulted from it.

> Attaching net device to a bridge _once_ should not changed its default
> configuration, moreover it's a subtle change without any message that
> user won't noticed at all.

IMHO the key point here is that LRO enabled when it shouldn't is much
more serious problem than LRO disabled when it could be enabled.

                                                       Michal Kubecek
