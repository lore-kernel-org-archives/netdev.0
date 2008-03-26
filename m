From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [RFC] [NET] [0/2] pskb_expand_head() bugfix
Date: Wed, 26 Mar 2008 16:47:35 -0400
Message-ID: <47EAB667.6010308@redhat.com>
References: <47E946C8.6020006@redhat.com> <20080325235536.GB30298@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, haoki@redhat.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43292 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757979AbYCZUrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 16:47:47 -0400
In-Reply-To: <20080325235536.GB30298@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Herbert,

Thank you for your quick response.

Herbert Xu wrote:
> On Tue, Mar 25, 2008 at 02:39:04PM -0400, Hideo AOKI wrote:
>>
>> Current pskb_expand_head() doesn't change truesize, while it
>> reallocates memory. Then, if argument nhead or ntail aren't 0, caller
>> must update truesize.
>>
>> We had this bug at audit_expand() in January and fixed it as commit
>> 406a1d868001423c85a3165288e566e65f424fe6. However, some drivers and
>> subsystems still use pskb_expand_head() without updating truesize.
> 
> Drivers usually aren't supposed to change truesize so doing
> this would actually create bugs.

I understood your point. 

Since keeping correct truesize is important to network memory
accounting, I want to fix network subsystem part at least.

I think that it is inconvenient for caller functions to need
updateing truesize by themselves. How about this change to
avoid the inconvenience?

 - Current implementation is renamed to __pskb_expand_head().
 - Drivers call __pskb_expand_head() instead of pskb_expand_head().
 - New pskb_expand_head() updates truesize after calling 
  __pskb_expand_head(). 

Or, should I simply add truesize calculation after
pskb_expand_head() calls which change truesize?
 
>> In addition, there is another problem to update truesise. Since
>> pskb_expand_head() aligns memory size before reallocation, caller
>> functions may not update turesize correctly if they just add nhaad
>> and ntail to turesize.
> 
> That should be fixable by making sure that nhead + ntail is
> aligned.

I see.

Regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.

