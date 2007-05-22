From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: [Xen-devel] Re: [PATCH 3/4] [Net] Support Xen accelerated
	network plugin modules
Date: Tue, 22 May 2007 15:20:01 +0100
Message-ID: <1179843601.28562.55.camel@moonstone.uk.level5networks.com>
References: <C278B79D.F53F%keir@xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: muli@il.ibm.com, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	herbert@gondor.apana.org.au
To: Keir Fraser <keir@xensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:13590 "EHLO
	OCEX01.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756247AbXEVOUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 10:20:06 -0400
In-Reply-To: <C278B79D.F53F%keir@xensource.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-05-22 at 15:07 +0100, Keir Fraser wrote:
> On 22/5/07 13:44, "Kieran Mansley" <kmansley@solarflare.com> wrote:
> 
> >> Eagerly zap the function pointers, then wait one RCU period so every CPU
> >> goes through a quiescent point before unloading the module?
> >> 
> >>  -- Keir
> > 
> > Am I right in thinking that if one of the functions that was protected
> > by RCU was to block, that would be a bad thing?  Clearly the data path
> > hooks can't/don't block, but I'm not sure it's so obvious for things
> > like probing a new device.
> 
> Are there still module reference counts? If so, functions which may block
> can manipulate their module's reference count.
> 
> Or if not, I guess the accelerator module can have a private reference count
> checked by whatever unload function gets called from the RCU subsystem. So
> that unload becomes deferred until *both* an RCU phase has passed *and* a
> reference count has fallen to zero.

That's true I suppose, but it replaces the current spinlock and ref
count with an RCU and a ref count, so does little to address the
complexity that Stephen Hemminger was rightly concerned about.  It does
I suppose put the complexity in the plugin module rather than netfront,
and only have it when necessary, which might make it better, but makes
the job of writing the plugin modules harder and more prone to bugs. 

Kieran

