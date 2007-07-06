From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based =?iso-8859-1?q?PCI=09Express?= adapters...
Date: Fri, 6 Jul 2007 10:46:35 +0200
Message-ID: <200707061046.37035.netdev@axxeo.de>
References: <20070612234417.5102.29147.stgit@localhost.localdomain> <46891A99.7090003@garzik.org> <46891FC9.9060307@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:60000 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755196AbXGFJGi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 05:06:38 -0400
In-Reply-To: <46891FC9.9060307@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Auke,

Kok, Auke schrieb:
> tg3.c:
> 
> 	if ((tp->tg3_flags & TG3_FLAG_PCIX_TARGET_HWBUG) ||
> 	    (tp->tg3_flags2 & TG3_FLG2_ICH_WORKAROUND))
> 
> is obviously _not_ easier to read than
> 
>          if (tp->tg3_flags.pcix_target_hwbug || tp->tg3_flags.ich_workaround)
> 

Yes, but what about:

static bool tg3_has_pcix_target_hwdebug(const struct tg3 *tp)
{
	return (tp->tg3_flags & TG3_FLAG_PCIX_TARGET_HWBUG) != 0;
}

static bool tg3_has_ich_workaround(const struct tg3 *tp)
{
	return (tp->tg3_flags2 & TG3_FLG2_ICH_WORKAROUND) != 0;
}

if (tg3_has_pcix_target_hwdebug(tp) || tg3_has_ich_workaround(tp)) {
	/* do foo */
}

That is just as nice as bitfields and makes that stuff more readable.
This is also a migration path while going from bitfields to flags incrementally.

If you find out that two of these tests are always done together you could even 
test two of them in one.

> I would say that this method is definately worse for readability. 

Yes, open coding this bit masking mess IS making code hardly readable!

> I would much rather then stick with 'bool' instead.

If you can afford the space, that is just as good. If you are undecided,
try the accessors. You can even write code, which generates them once. 

Maybe we could get such nice script for generating 
a set of bitmasks and accessors in the kernel :-)

Source would than be a struct definition with bitfields.

All points raised be the people here are actually valid and I consider
bitfields nice and clear for specification and example code, 
but avoid them while doing real coding.


Best Regards

Ingo Oeser
