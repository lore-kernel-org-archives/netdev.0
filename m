From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] sched: remove NET_XMIT_POLICED
Date: Sat, 11 Jun 2016 00:00:47 -0700 (PDT)
Message-ID: <20160611.000047.2179423929953796335.davem@davemloft.net>
References: <1465561289-15401-1-git-send-email-fw@strlen.de>
	<20160610.233137.888795126611100309.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, a@unstable.cc, sw@simonwunderlich.de,
	mareklindner@neomailbox.ch, sven@narfation.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35407 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbcFKHAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 03:00:49 -0400
In-Reply-To: <20160610.233137.888795126611100309.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 10 Jun 2016 23:31:37 -0700 (PDT)

> From: Florian Westphal <fw@strlen.de>
> Date: Fri, 10 Jun 2016 14:21:29 +0200
> 
>> ... its not returned anywhere.
>> 
>> BATMAN uses it as an intermediate return value to signal
>> forwarding vs. buffering, but it will not return POLICED to
>> callers outside of BATMAN.
>> 
>> sch_atm uses it, but on closer look its not returned either since
>> the initialisation is always overwritten with qdisc_enqueue() retval.
>> 
>> Signed-off-by: Florian Westphal <fw@strlen.de>
> 
> Applied, thanks.

I have to revert this, the sch_atm.c change is wrong.

NET_XMIT_POLICED is the default value of 'ret' which can be used
if we branch to 'drop'.  So now GCC says that 'ret' might be used
uninitialized.

So it is actually used, and reported by sch_atm when TC_ACT_SHOT
classifications occur.
