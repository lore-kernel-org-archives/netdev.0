From: David Miller <davem@davemloft.net>
Subject: Re: [take21 0/4] kevent: Generic event handling mechanism.
Date: Tue, 07 Nov 2006 12:52:41 -0800 (PST)
Message-ID: <20061107.125241.39157521.davem@davemloft.net>
References: <20061107115111.GA13028@2ka.mipt.ru>
	<45507CD4.5030600@garzik.org>
	<20061107113400.880e1ce9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, johnpol@2ka.mipt.ru, drepper@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	torvalds@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63453
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1753255AbWKGUwk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 15:52:40 -0500
To: akpm@osdl.org
In-Reply-To: <20061107113400.880e1ce9.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Tue, 7 Nov 2006 11:34:00 -0800

> What Evgeniy means here is that copy_to_user() is slower than memcpy() (on
> his machine, with his kernel config, at least).
> 
> Which is kinda weird and unexpected and is something which we should
> investigate independently from this project.  (Rather than simply going
> and bypassing it!)

It's straightforward to me. :-)

If the kerne memcpy()'s, it uses those nice 4MB PTE mappings to
the kernel pages.  With copy_to_user() you run through tiny
4K or 8K PTE mappings which thrash the TLB.

The TLB is therefore able to hold more of the accessed state at
a time if you touch the pages on the kernel side.
