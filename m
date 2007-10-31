From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] - e1000_ethtool.c - convert macros to functions
Date: Wed, 31 Oct 2007 16:15:56 -0700
Message-ID: <1193872556.11020.34.camel@localhost>
References: <1193865488.11020.11.camel@localhost>
	 <4728F3E1.1040908@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net,
	Jeff Garzik <jgarzik@pobox.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3439 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752946AbXJaXQC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 19:16:02 -0400
In-Reply-To: <4728F3E1.1040908@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-10-31 at 14:30 -0700, Kok, Auke wrote:
> Joe Perches wrote:
> that's not a bad idea, however see below:
> can't we keep the macro here (and just make it call the function instead of
> expanding). the resulting code is much more lenghty and contains all these logic
> traps that the previous code didn't have.
> just have the macro expand to `if (reg_pattern_test(...)) return 1)` and you don't
> need to change any of the calling lines.

You could define something like:

#define REG_PATTERN_TEST(reg, mask, write) \
	if (reg_pattern_test(adapter, data, \
			     E1000_REG(&adapter->hw, reg), \
			     mask, write)) \
		return 1;

But isn't the macro with an embedded return a bit too obfuscating?

> > +#define E1000_READ_REG_ARRAY(a, reg, offset)		\
> > +	(readl((a)->hw_addr +				\
> > +	       (((a)->mac_type >= e1000_82543)		\
> > +		? E1000_##reg : E1000_82542_##reg) +	\
> > +	       ((offset) << 2)))
> 
> did you have to change these macro's ?

No.  Your choice to keep/remove.
I did want to use the E1000_REG or a new E1000_REG_ADDR macro.

> also, I'm a bit inclined to prefer a patch for e1000e for now as we're about to
> move the pci-express hardware over, but we can certainly merge something like this
> in e1000 after the move as well.

Simple enough.

When is e1000e scheduled to be part of defconfig?

cheers,  Joe

