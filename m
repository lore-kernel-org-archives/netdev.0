From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Compact sk_stream_mem_schedule() code
Date: Mon, 19 Nov 2007 23:22:45 -0800 (PST)
Message-ID: <20071119.232245.246671296.davem@davemloft.net>
References: <47417DF8.6040204@openvz.org>
	<20071119193059.GA5211@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, devel@openvz.org, netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33156
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752880AbXKTHWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 02:22:46 -0500
In-Reply-To: <20071119193059.GA5211@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 19 Nov 2007 17:30:59 -0200

> Em Mon, Nov 19, 2007 at 03:13:44PM +0300, Pavel Emelyanov escreveu:
> > This function references sk->sk_prot->xxx for many times.
> > It turned out, that there's so many code in it, that gcc 
> > cannot always optimize access to sk->sk_prot's fields.
> > 
> > After saving the sk->sk_prot on the stack and comparing
> > disassembled code, it turned out that the function became
> > ~10 bytes shorter and made less dereferences (on i386 and 
> > x86_64). Stack consumption didn't grow.
> > 
> > Besides, this patch drives most of this function into the
> > 80 columns limit.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> I wonder if making it 'const struct proto *prot = sk->sk_prot;'
> 
> would make any difference.

Such experiments are always useful, but I doubt there will
be substantial gains in this case.

> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

I've applied the patch, thanks Pavel.
