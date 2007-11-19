From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH] Compact sk_stream_mem_schedule() code
Date: Mon, 19 Nov 2007 17:30:59 -0200
Message-ID: <20071119193059.GA5211@ghostprotocols.net>
References: <47417DF8.6040204@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, devel@openvz.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.231]:12871 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbXKSTbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 14:31:07 -0500
Received: by nz-out-0506.google.com with SMTP id s18so1377963nze
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 11:31:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47417DF8.6040204@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Nov 19, 2007 at 03:13:44PM +0300, Pavel Emelyanov escreveu:
> This function references sk->sk_prot->xxx for many times.
> It turned out, that there's so many code in it, that gcc 
> cannot always optimize access to sk->sk_prot's fields.
> 
> After saving the sk->sk_prot on the stack and comparing
> disassembled code, it turned out that the function became
> ~10 bytes shorter and made less dereferences (on i386 and 
> x86_64). Stack consumption didn't grow.
> 
> Besides, this patch drives most of this function into the
> 80 columns limit.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

I wonder if making it 'const struct proto *prot = sk->sk_prot;'

would make any difference.

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
