From: Andrew Morton <akpm@osdl.org>
Subject: Re: [take21 0/4] kevent: Generic event handling mechanism.
Date: Tue, 7 Nov 2006 13:38:03 -0800
Message-ID: <20061107133803.4487a666.akpm@osdl.org>
References: <20061107115111.GA13028@2ka.mipt.ru>
	<45507CD4.5030600@garzik.org>
	<20061107113400.880e1ce9.akpm@osdl.org>
	<20061107.125241.39157521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, johnpol@2ka.mipt.ru, drepper@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	torvalds@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55767 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1753421AbWKGVjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 16:39:11 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061107.125241.39157521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 07 Nov 2006 12:52:41 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@osdl.org>
> Date: Tue, 7 Nov 2006 11:34:00 -0800
> 
> > What Evgeniy means here is that copy_to_user() is slower than memcpy() (on
> > his machine, with his kernel config, at least).
> > 
> > Which is kinda weird and unexpected and is something which we should
> > investigate independently from this project.  (Rather than simply going
> > and bypassing it!)
> 
> It's straightforward to me. :-)
> 
> If the kerne memcpy()'s, it uses those nice 4MB PTE mappings to
> the kernel pages.  With copy_to_user() you run through tiny
> 4K or 8K PTE mappings which thrash the TLB.
> 
> The TLB is therefore able to hold more of the accessed state at
> a time if you touch the pages on the kernel side.

Maybe.  Evgeniy tends to favour teeny microbenchmarks.  I'd also be
suspecting the considerable setup code in the x86 uaccess funtions.  That
would show up in a tight loop doing large numbers of small copies.
