From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] net, llc: Avoid undefined behaviour in
 llc_conn_ac_inc_vr_by_1()
Date: Sun, 26 Jun 2011 02:01:05 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106260158450.23991@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1106260009530.23991@swampdragon.chaosbits.net> <20110625.170445.957364657527336185.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:42700 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075Ab1FZAKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 20:10:06 -0400
In-Reply-To: <20110625.170445.957364657527336185.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Jun 2011, David Miller wrote:

> From: Jesper Juhl <jj@chaosbits.net>
> Date: Sun, 26 Jun 2011 00:11:12 +0200 (CEST)
> 
> > Introduce a sequence point (;) between two writes to llc_sk(sk)->vR in
> > net/llc/llc_c_ac.c:llc_conn_ac_inc_vr_by_1() so that the order in
> > which the writes happen become well defined.
> > 
> > While the code may work fine now it may break at any time with a
> > different compiler, a new version of current compiler or even just a
> > different optimization level of the current compiler. Much better to
> > clearly express what's intended in a way that guarantees the result.
> > 
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> 
> How about fixing the macro so that it doesn't have side effects
> like this?
> 
> That's much better than a 6 line (improperly formatted, BTW) comment
> every time someone tried to use that macros with an lvalue that isn't
> a local variable.

Sure, that's also a way to go - better probably.
I just thought that I would fix up the one call site I found that was 
problematic...
But gimme a couple of days (I don't have much free time) and I'll cook up 
a different patch.

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

