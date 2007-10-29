From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] pcnet: fix sparse triviality
Date: Mon, 29 Oct 2007 10:54:25 -0700
Message-ID: <47261E51.2000301@intel.com>
References: <20071026221132.1913.24518.stgit@localhost.localdomain> <4725B045.80705@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: pcnet32@verizon.net, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37244 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752608AbXJ2SDd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 14:03:33 -0400
In-Reply-To: <4725B045.80705@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Auke Kok wrote:
>> Since data can never exceed u32, it can't even be larger than
>> LONG_MAX/HZ.
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> Cc: pcnet32@verizon.net
>> ---
>>
> Two comments:
> 
> 1) I would prefer to pick a sane limit, like "1 day".  The unit of
> 'data' is seconds, so IMO we should not allow stupid timeouts, much less
> INT_MAX ones :)  But hey, then again, maybe we should permit root to
> hang themselves with own rope...

well, in this case it's only used for the blink interval for the LED on the back
of the adapter. This is completely interruptable by the user with ^C when running
ethtool, so it's not going to hang anything (traffic should continue nicely).

yes INT_MAX is insanely long. moving all of this checking to the ethtool generic
code makes much more sense indeed.

> 2) [tangent] someone really should add the obvious ssleep_interruptible()

*pass* :)

Auke
