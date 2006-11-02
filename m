From: Florian Westphal <fw-kernel@strlen.de>
Subject: Re: [tipc-discussion] [KJ] [patch] net/tipc: sprintf/strcpy conversion
Date: Thu, 2 Nov 2006 07:26:56 +0100
Message-ID: <20061102062656.GA8339@Chamillionaire.breakpoint.cc>
References: <20061101140624.GA7694@Chamillionaire.breakpoint.cc> <454913D2.9050608@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:3246 "EHLO
	Chamillionaire.breakpoint.cc") by vger.kernel.org with ESMTP
	id S1752309AbWKBG13 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 01:27:29 -0500
To: tipc-discussion@lists.sourceforge.net,
	kernel-janitors@lists.osdl.org, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <454913D2.9050608@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

walter harms <wharms@bfs.de> wrote:
> These line
>+       strcpy(bcbearer->media.name, "tipc-multicast");
> i gues that means tipc_bclink_name ?

The idea was to change how things are done, not _what_ is being done.

> an even more secure version could be like this:
> 
> 	strncpy(bcbearer->media.name,sizeof(bcbearer->media.name),tipc_bclink_name);

Ugh, please, no. The size of src is known in all cases; there is
absoluty no point in using str(n|l)cpy here.

> (in case someone ever changes the size of cbearer->media.name or tipc_bclink_name and the hope
> that wchat_t will never reach the kernel)

In this case 'someone' should be really hurt, don't you think?

Florian
