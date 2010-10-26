From: David Miller <davem@davemloft.net>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Tue, 26 Oct 2010 11:43:21 -0700 (PDT)
Message-ID: <20101026.114321.27791534.davem@davemloft.net>
References: <1287851745.2658.364.camel@edumazet-laptop>
	<239681287855420@web159.yandex.ru>
	<1287863065.2658.533.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sysoleg@yandex.ru, netdev@vger.kernel.org, aspam@cox.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57220
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752045Ab0JZSm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 14:42:58 -0400
In-Reply-To: <1287863065.2658.533.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 23 Oct 2010 21:44:25 +0200

> [PATCH] fib: fix fib_nl_newrule()
> 
> Some panic reports in fib_rules_lookup() show a rule could have a NULL
> pointer as a next pointer in the rules_list.
> 
> This can actually happen because of a bug in fib_nl_newrule() : It
> checks if current rule is the destination of unresolved gotos. (Other
> rules have gotos to this about to be inserted rule)
> 
> Problem is it does the resolution of the gotos before the rule is
> inserted in the rules_list (and has a valid next pointer)
> 
> Fix this by moving the rules_list insertion before the changes on gotos.
> 
> A lockless reader can not any more follow a ctarget pointer, unless
> destination is ready (has a valid next pointer)
> 
> Reported-by: Oleg A. Arkhangelsky <sysoleg@yandex.ru>
> Reported-by: Joe Buehler <aspam@cox.net>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
