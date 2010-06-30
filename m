From: Anton Vorontsov <avorontsov@mvista.com>
Subject: Re: [PATCH 1/3] gianfar: Implement workaround for eTSEC74 erratum
Date: Wed, 30 Jun 2010 20:38:04 +0400
Message-ID: <20100630163804.GA636@oksana.dev.rtsoft.ru>
References: <20100629205959.GA10905@oksana.dev.rtsoft.ru>
 <20100629.151626.90794001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: manfred.rudigier@omicron.at, Sandeep.Kumar@freescale.com,
	afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:24698 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754743Ab0F3QiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 12:38:10 -0400
Content-Disposition: inline
In-Reply-To: <20100629.151626.90794001.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 29, 2010 at 03:16:26PM -0700, David Miller wrote:
> 
> I really don't see any value at all to this config option,
> the errata fixup code should be there all the time.

Well, at least for eTSEC76 erratum (patch 2/3) we have to touch
fast path (i.e. start_xmit), so I just wanted to make zero
overhead for controllers that don't need any fixups.

Not that there's much of the overhead in a single additional
'if' condition, no. ;-)

> It really does no harm to be there in the cases where it isn't
> used, and forcing users to turn this on is just another
> obscure way to end up with an incorrect configuration.

OK, resending the new patches, without Kconfig stuff...

If we'll have too many or too big errata so that it would cause
major performance or code size penalty for non-affected SOCs, we
can always do:

enum gfar_errata {
#ifdef CONFIG_PPC_FOO
	GFAR_ERRATA_FOO = 0x01,
#else
	GFAR_ERRATA_FOO = 0,
#endif
}

And then, priv->errata & GFAR_ERRATA_FOO will be optimized
away by the compiler.

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
