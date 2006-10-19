From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] Size listen hash tables using backlog hint
Date: Wed, 18 Oct 2006 23:12:18 -0700 (PDT)
Message-ID: <20061018.231218.74744257.davem@davemloft.net>
References: <200610171458.37636.dada1@cosmosbay.com>
	<20061018.203109.63997999.davem@davemloft.net>
	<4537095A.9010705@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:13249
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030310AbWJSGNE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 02:13:04 -0400
To: dada1@cosmosbay.com
In-Reply-To: <4537095A.9010705@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 19 Oct 2006 07:12:58 +0200

> A 66 MHz 486 can perform 1.000.000 divisions per second. Is it a 'slow' cpu ?

Sparc and some other embedded chips have no division/modulus integer
instruction and do it in software.

> So... what do you prefer :
> 
> 1) Keep the modulus
> 2) allocate two blocks of ram (powser-of -two hash size, but one extra 
> indirection)
> 3) waste near half of ram because one block allocated, and power-of-two hash size.

I thought the problem was that you use a modulus and non-power-of-2
hash table size because rounding up to the next power of 2 wastes
a lot of space?  Given that, my suggestion is simply to not round
up to the next power-of-2, or only do so when we are very very close
to that next power-of-2.
