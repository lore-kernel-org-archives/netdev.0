From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [NET] [0/2] pskb_expand_head() bugfix
Date: Thu, 27 Mar 2008 16:48:20 -0700 (PDT)
Message-ID: <20080327.164820.194326039.davem@davemloft.net>
References: <47E946C8.6020006@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: haoki@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32780
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752534AbYC0XsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 19:48:20 -0400
In-Reply-To: <47E946C8.6020006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hideo AOKI <haoki@redhat.com>
Date: Tue, 25 Mar 2008 14:39:04 -0400

> Current pskb_expand_head() doesn't change truesize, while it
> reallocates memory. Then, if argument nhead or ntail aren't 0, caller
> must update truesize.
> 
> We had this bug at audit_expand() in January and fixed it as commit
> 406a1d868001423c85a3165288e566e65f424fe6. However, some drivers and
> subsystems still use pskb_expand_head() without updating truesize.
> 
> In addition, there is another problem to update truesise. Since
> pskb_expand_head() aligns memory size before reallocation, caller
> functions may not update turesize correctly if they just add nhaad
> and ntail to turesize.

Drivers may not update truesize, because as I explained in
Tokyo a fundamental issue is the case where SKB is charged
already to a socket.  In such a case, skb->truesize may not
be modified without corrupting socket write queue allocation
state.

And at these very spots in drivers, the transmit path, the
SKB is very likely to be owned by a socket.
