From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [RFC] [NET] [0/2] pskb_expand_head() bugfix
Date: Fri, 28 Mar 2008 21:02:41 -0400
Message-ID: <47ED9531.7060901@redhat.com>
References: <47E946C8.6020006@redhat.com> <20080327.164820.194326039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	haoki@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34393 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755371AbYC2BCq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 21:02:46 -0400
In-Reply-To: <20080327.164820.194326039.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

David Miller wrote:
> From: Hideo AOKI <haoki@redhat.com>
> Date: Tue, 25 Mar 2008 14:39:04 -0400
> 
>> Current pskb_expand_head() doesn't change truesize, while it
>> reallocates memory. Then, if argument nhead or ntail aren't 0, caller
>> must update truesize.
>>
>> We had this bug at audit_expand() in January and fixed it as commit
>> 406a1d868001423c85a3165288e566e65f424fe6. However, some drivers and
>> subsystems still use pskb_expand_head() without updating truesize.
>>
>> In addition, there is another problem to update truesise. Since
>> pskb_expand_head() aligns memory size before reallocation, caller
>> functions may not update turesize correctly if they just add nhaad
>> and ntail to turesize.
> 
> Drivers may not update truesize, because as I explained in
> Tokyo a fundamental issue is the case where SKB is charged
> already to a socket.  In such a case, skb->truesize may not
> be modified without corrupting socket write queue allocation
> state.
> 
> And at these very spots in drivers, the transmit path, the
> SKB is very likely to be owned by a socket.

Thank you for explaining.

OK. I don't change driver code to avoid double charge.

Best regards,
Hideo

--
Hitachi Computer Products (America) Inc.
