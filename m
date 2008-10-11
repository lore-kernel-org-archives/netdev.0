From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking for 2.6.28
Date: Sat, 11 Oct 2008 13:10:52 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0810111303510.3402@nehalem.linux-foundation.org>
References: <20081010.144921.115563930.davem@davemloft.net> <alpine.LFD.2.00.0810110941330.3402@nehalem.linux-foundation.org> <alpine.LFD.2.00.0810111057020.3402@nehalem.linux-foundation.org> <20081011.121930.193700319.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Philip Langdale <philipl@overt.org>,
	Henrique de Moraes Holschuh <hmh@hmh.eng.br>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49751 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754142AbYJKULQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 16:11:16 -0400
In-Reply-To: <20081011.121930.193700319.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 11 Oct 2008, David Miller wrote:
> 
> So the proper include (of net/ip.h) is there in ip_vs_xmit.c, but this
> failure can also happen if CONFIG_INET is not enabled.
> 
> Are you doing that kind of test build?

No, but somebody is.

> This patch should fix that case, let me know if it works:

How about you test it? It wasn't my bug-report, I just reported another 
report from somebody who _does_ run randconfig.

Here's another one:

	drivers/built-in.o: In function `bt_poll_rfkill':
	toshiba_acpi.c:(.text+0x37346): undefined reference to `input_event'

where the cause seems to be a totally broken Kconfig entry ACPI_TOSHIBA.

You can't just do

	select INPUT_POLLDEV

since that in turn needs all the _other_ input stuff. Yes, yes, things 
like various keyboard drivers do exactly that, but they are already inside 
"if INPUT_KEYBOARD/INPUT_MISC" or similar.

So at the very least, you'd now have to have it do a "depends on INPUT" or 
something like that.

Or perhaps just make that particular _feature_ depend on it, rather than 
make the whole driver depend on or select it. 

		Linus
