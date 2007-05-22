From: Keir Fraser <keir@xensource.com>
Subject: Re: [Xen-devel] Re: [PATCH 3/4] [Net] Support Xen accelerated
 network plugin modules
Date: Tue, 22 May 2007 15:07:09 +0100
Message-ID: <C278B79D.F53F%keir@xensource.com>
References: <1179837868.28562.22.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <muli@il.ibm.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xensource.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	<herbert@gondor.apana.org.au>
To: Kieran Mansley <kmansley@solarflare.com>,
	Keir Fraser <keir@xensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 207.47.60.4.static.nextweb.net ([207.47.60.4]:53729 "EHLO
	rpc.xensource.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757609AbXEVOHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 10:07:22 -0400
In-Reply-To: <1179837868.28562.22.camel@moonstone.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/5/07 13:44, "Kieran Mansley" <kmansley@solarflare.com> wrote:

>> Eagerly zap the function pointers, then wait one RCU period so every CPU
>> goes through a quiescent point before unloading the module?
>> 
>>  -- Keir
> 
> Am I right in thinking that if one of the functions that was protected
> by RCU was to block, that would be a bad thing?  Clearly the data path
> hooks can't/don't block, but I'm not sure it's so obvious for things
> like probing a new device.

Are there still module reference counts? If so, functions which may block
can manipulate their module's reference count.

Or if not, I guess the accelerator module can have a private reference count
checked by whatever unload function gets called from the RCU subsystem. So
that unload becomes deferred until *both* an RCU phase has passed *and* a
reference count has fallen to zero.

 -- Keir

