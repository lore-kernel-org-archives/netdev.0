From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Fri, 09 Jan 2009 01:28:22 -0500
Message-ID: <4966EE86.3030704@pobox.com>
References: <20090109041952.GA12087@gondor.apana.org.au> <4966DABD.1000203@pobox.com> <20090109051500.GA12836@gondor.apana.org.au> <4966E0ED.9090905@pobox.com> <20090109053520.GA13219@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, rick.jones2@hp.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59723 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752447AbZAIG2f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 01:28:35 -0500
In-Reply-To: <20090109053520.GA13219@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Jan 09, 2009 at 12:30:21AM -0500, Jeff Garzik wrote:
>> Actually it's just the opposite -- _the_ most common complaint from  
>> users and driver developers of the ethtool interface, over the years,  
>> has been that there is no way to collect all the modifications and then  
>> commit it to hardware all in one go.
> 
> Yes that's a problem for flags that require the drivers to reset
> itself.
> 
>> Each new ethtool command added often winds up pausing and resetting the  
>> hardware completely, and ETHTOOL_SGRO is no exception.
> 
> But as I explained before, GRO (like GSO) is purely a software
> setting, it has nothing to do with the driver at all.  In other

Not quite true...  it touches the driver's rx-csum hook.


> If anything by going into the driver's set_flags function as you
> suggested may cause a spurious reset that wouldn't have happened
> otherwise.
> 
> So for software flags like GSO/GRO at least, I don't see any
> benefit in going to a multi-bit interface.  On the flip side,
> I see potential complications with a multi-bit interfaces that
> simply don't exist with a single-bit interface.

Well, whichever.  Overall, if [GS]GRO remains I am happy to take patches 
supporting it in the userspace utility...

	Jeff


