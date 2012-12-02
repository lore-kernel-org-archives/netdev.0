From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/17] ATM fixes for pppoatm/br2684
Date: Sat, 01 Dec 2012 21:17:28 -0500 (EST)
Message-ID: <20121201.211728.1605970407761696599.davem@davemloft.net>
References: <1354382493.21562.347.camel@shinybook.infradead.org>
	<201212020157.qB21vZiN011233@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@vger.kernel.org, krzysiek@podlesie.net
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602Ab2LBCRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 21:17:32 -0500
In-Reply-To: <201212020157.qB21vZiN011233@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Date: Sat, 01 Dec 2012 20:57:35 -0500

> In message <1354382493.21562.347.camel@shinybook.infradead.org>,David Woodhouse writes:
>>Possibly not even a bug at all, in fact =E2=80=94 GCC is fairly loose with =
>>those
>>warnings. But if it is a bug it's my fault. I'll take a look at that
>>too. Not tonight though; I'm going out shortly and will only just manage
>>the solos-pci fix.
> 
> it is not a bug, just gcc being pedantic.  gcc doesn't believe
> that passing by reference it a form of initilization.

It's not that, it actually is analyzing the initializations done by
that function call during inlining.

What it can't see is the case where multiple flows of control have
different treatments of a variable.

It can't see that, for example, all paths that test boolean X do not
touch the uninitialized variable.  It doesn't analyze the
inter-dependencies of each code path in enough detail to know for
certain.
