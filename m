From: Joe Buehler <aspam@cox.net>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Sat, 23 Oct 2010 11:40:35 -0400
Message-ID: <4CC301F3.5010504@cox.net>
References: <loom.20101012T185411-307@post.gmane.org>	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>	 <1287805487.2658.5.camel@edumazet-laptop>	 <1287846669.2658.247.camel@edumazet-laptop> <1287847465.2658.266.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Daney <ddaney@caviumnetworks.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmmtao104.cox.net ([68.230.240.46]:43737 "EHLO
	eastrmmtao104.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757581Ab0JWPkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Oct 2010 11:40:37 -0400
In-Reply-To: <1287847465.2658.266.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
>
> David Daney added a nudge_writes(), actually doing a "syncw"
> instruction, and this seems to be the smp_wmb() this platform should be
> using in the first place, not a pure compiler barrier (barrier()) 
>
> So Joe, you might want to change the smp_wmb() call in
> rcu_assign_pointer() by the nudge_writes() call, and see what happens...
>
>
>   

I think Daney is Cavium's Octeon LINUX guru from the posts I've seen so
he would definitely know the platform.  I'm not sure I quite understand
what you are saying but it sounds as though you are saying that smp_wb
is not doing a syncw and that sounds *totally* broken -- snycw is what
the low-level Cavium SDK uses for memory barriers all over the place.

Joe Buehler

