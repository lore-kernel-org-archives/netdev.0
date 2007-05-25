From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/4] [Net] Support Xen accelerated network plugin modules
Date: 25 May 2007 08:53:12 +0200
Message-ID: <p73k5uxcs2v.fsf@bingen.suse.de>
References: <1179494208.14376.10.camel@moonstone.uk.level5networks.com>
	<20070521105258.7988fd6e@freepuppy>
	<1179818108.4145.18.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	muli@il.ibm.com, herbert@gondor.apana.org.au
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52114 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754487AbXEYF4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 May 2007 01:56:35 -0400
In-Reply-To: <1179818108.4145.18.camel@moonstone.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kieran Mansley <kmansley@solarflare.com> writes:

> RCU on its own wouldn't
> prevent the accelerated plugin being unloaded while netfront was using
> one of the hooks. 

Note that module unload does always does a stop_machine() which is much 
stronger than normal RCU. As long as you don't sleep and cannot be preemptable
it should be always safe.

-Andi
