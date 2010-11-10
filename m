From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] Fix CAN info leak/minor heap overflow
Date: Wed, 10 Nov 2010 23:10:24 +0100
Message-ID: <4CDB1850.3060204@hartkopp.net>
References: <4CD8FDB5.6060905@hartkopp.net>	<20101109.090523.189685701.davem@davemloft.net>	<4CDA412B.90900@hartkopp.net> <20101110.095141.226780406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, netdev@vger.kernel.org,
	drosenberg@vsecurity.com, security@kernel.org,
	torvalds@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:45403 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756610Ab0KJWKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 17:10:43 -0500
In-Reply-To: <20101110.095141.226780406.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10.11.2010 18:51, David Miller wrote:
> From: Oliver Hartkopp <socketcan@hartkopp.net>
> Date: Wed, 10 Nov 2010 07:52:27 +0100
> 
>> IMHO the patch improves the historic situation and fixes the useless leakage
>> of kernel addresses. Please consider to apply that procfs changes.
> 
> I'm only fine with fixing the kernel pointer fields in some way.
> 
> But moving forward any other change to the procfs file is simply
> a waste of time.
> 
> You should create sysfs files and add logic to your tools to look
> for them and use them if they exist.
> 
> Your forward path _SHOULD NOT_ be continuing this procfs versioning
> madness.  Use something sane and do the work to make userland start
> to be ready for this transition.

Hm, summarizing the given restrictions and taking into account that just
setting the pointer fields to '0' is said to be annoying, the only thing that
can be fixed is the minor heap overflow caused by the char array. I'll send a
patch for that.

As you don't want to change the layout even if there's no tool relying on the
entries i wanted to modify, i'll just stop my attempts to improve it.

Regards,
Oliver


