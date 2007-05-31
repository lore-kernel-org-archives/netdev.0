From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: REGRESSION: panic on e1000 driver
Date: Thu, 31 May 2007 07:54:31 -0700
Message-ID: <465EE1A7.6050901@intel.com>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net> <465E0149.6030307@intel.com> <20070531005147.GA30628@gondor.apana.org.au> <465E5442.7010503@intel.com> <20070531050616.GA32391@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Doug Chapman <doug.chapman@hp.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:19904 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752731AbXEaOyo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 10:54:44 -0400
In-Reply-To: <20070531050616.GA32391@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Wed, May 30, 2007 at 09:51:14PM -0700, Kok, Auke wrote:
>> this has been an age-old confusion that I never grasped either, so I 
>> perfectly understand why you added the explicit e1000_disable_irq call in 
>> the other patch (and think thats a great idea). But really, there should be 
>> a way for a driver to tell the stack that it should really keep it's hands 
>> off :)
> 
> Well yes, you can get the stack to keep away by not registering your
> device :)

*blunt*

so how about calling netif_poll_disable() before we register the net_device?

>> BTW e1000 currently triggers a single irq manually in the watchdog as link 
>> goes up, so that might be the one that is giving problems now. In any case 
>> I can't reproduce any of it - perhaps my hardware is too fast. Time to whip 
>> out the pIII :o
> 
> Hmm, if it's triggered by the watchdog then that means the watchdog has
> been scheduled.  However, it seems that the only way to schedule it is
> through an interrupt?

well no, if we make the watchdog (this is something I've already implemented 
locally and -mm has it for instance) run as delayed work we can just schedule a 
watchdog run instead of firing an interrupt.

I'm just not sure that would relieve the situation

Auke
