From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Thu, 08 Jan 2009 22:58:17 -0500
Message-ID: <4966CB59.4090202@pobox.com>
References: <20090109034804.GA11741@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, rick.jones2@hp.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59189 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752158AbZAID61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 22:58:27 -0500
In-Reply-To: <20090109034804.GA11741@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Jeff Garzik <jgarzik@pobox.com> wrote:
>> The person who added this should have used the new flags interface, and 
>> added ETH_FLAG_GRO right next to the pre-existing ETH_FLAG_LRO.
>>
>> It is incorrect to add new ioctls just to toggle a boolean value.
> 
> Well you missed my earlier explanation.  GRO is a stack flag,
> it's not something we want the device drivers to touch at all.
> 
> The generic flags interface appears to be designed for flags
> that the device driver directly controls, such as LRO.  That's
> why it is inappropriate for GRO, which like GSO is entirely done
> in software.

Nope, the generic flags interface is for any time you have a boolean 
flag to control on a per-interface basis.

The generic flags interface was created precisely because it is silly to 
keep creating _two_ ethtool sub-ioctls (get, set) just for single 
boolean flags.

For generic net stack flags outside the driver's control, that can 
easily be added to ethtool_{get,set}_flags() overriding or ignoring 
whatever the driver may have done.

	Jeff



