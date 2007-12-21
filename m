From: David Miller <davem@davemloft.net>
Subject: Re: [SOCK] Avoid integer divides where not necessary in
 include/net/sock.h
Date: Fri, 21 Dec 2007 03:06:40 -0800 (PST)
Message-ID: <20071221.030640.100066714.davem@davemloft.net>
References: <476B5AC0.9060604@cosmosbay.com>
	<20071221.015543.19719154.davem@davemloft.net>
	<20071221114051.f8310a6d.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44138
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753062AbXLULGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 06:06:41 -0500
In-Reply-To: <20071221114051.f8310a6d.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 21 Dec 2007 11:40:51 +0100

> On Fri, 21 Dec 2007 01:55:43 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> Please tell me if you are OK with this solution, or if you prefer
> I change sk_forward_alloc to be unsigned :)

When I was playing with this crap a long time ago I
think I remember that sk->sk_forward_alloc can become
negative in some circumstances.

Or maybe that was just a bug :-)

> Here is the patch handling the change on sk_wmem_queued, sk_sndbuf.
> Keeping small patches may help future bisection anyway...
> 
> [SOCK] Avoid integer divides where not necessary in include/net/sock.h
> 
> Because sk_wmem_queued, sk_sndbuf are signed, a divide per two
> may force compiler to use an integer divide.
> 
> We can instead use a right shift.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

I'll apply this, thanks Eric.
