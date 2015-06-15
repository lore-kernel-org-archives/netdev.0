From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Add sock_common_listen for TCP and DCCP
Date: Mon, 15 Jun 2015 14:54:46 -0700 (PDT)
Message-ID: <20150615.145446.1566874356874515092.davem@davemloft.net>
References: <1434085077-4938-1-git-send-email-firogm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, gerrit@erg.abdn.ac.uk,
	yoshfuji@linux-ipv6.org, jmorris@namei.org, kuznet@ms2.inr.ac.ru,
	herbert@gondor.apana.org.au, ast@plumgrid.com,
	ebiederm@xmission.com, dan.carpenter@oracle.com,
	Julia.Lawall@lip6.fr, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: firogm@gmail.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1434085077-4938-1-git-send-email-firogm@gmail.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Firo Yang <firogm@gmail.com>
Date: Fri, 12 Jun 2015 12:57:57 +0800

> Code refactoring:
> 1. Move the common code of inet_listen() and inet_dccp_listen() to
> sock_common_listen().
> 
> 2. Modify and rename inet_listen() to tcp_listen().
> 
> 3. Modify and rename inet_dccp_listen() to dccp_listen().
> 
> 4. Add new callback pointer listen in struct proto for
> tcp_listen() and dccp_listen().
> 
> This patch makes codes more modularized and removes redudant codes.
> 
> Signed-off-by: Firo Yang <firogm@gmail.com>
> ---
> v2: 
> In according to the advices of Eric Dumazet, sock_common_listen() keep 
> using TCP_xxx state instead of introducing new aliases.
> 
> Test info:
> I test it on my x86 PC.

I don't think this is worthwhile, sorry.

Instead of having two straight line copies of a piece of logic, we now
have three functions and a new callback.  I'd rather have a single
duplicate copy of a function than all of that.
