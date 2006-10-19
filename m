From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] Size listen hash tables using backlog hint
Date: Wed, 18 Oct 2006 23:57:47 -0700 (PDT)
Message-ID: <20061018.235747.74746971.davem@davemloft.net>
References: <4537095A.9010705@cosmosbay.com>
	<20061018.231218.74744257.davem@davemloft.net>
	<45371C8D.20603@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31911
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1945987AbWJSG6C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 02:58:02 -0400
To: dada1@cosmosbay.com
In-Reply-To: <45371C8D.20603@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 19 Oct 2006 08:34:53 +0200

> My main problem is being able to use a large hash table on big servers.
> 
> With power-of two constraint, plus kmalloc max size constraint, we can use 
> half the size we could.

Switch to vmalloc() at the kmalloc() cut-off point, just like
I did for the other hashes in the tree.

> Are you suggesting something like :

Not at all.

BTW, this all reminds me that we need to be careful that this
isn't allowing arbitrary users to eat up a ton of unswappable
ram.  It's pretty easy to open up a lot of listening sockets :)
