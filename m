From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3] netlink: fix null pointer dereference on nlk->groups
Date: Tue, 12 Jan 2016 20:00:19 +0800
Message-ID: <20160112120019.GA32718@gondor.apana.org.au>
References: <CAOJe8K10a=MLyZwFCYvstP+KG3bND09RjbXVZDR5gWfFxCvMcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sploving1@gmail.com, davem@davemloft.net, netdev@vger.kernel.org
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:48905 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964974AbcALMBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 07:01:01 -0500
Content-Disposition: inline
In-Reply-To: <CAOJe8K10a=MLyZwFCYvstP+KG3bND09RjbXVZDR5gWfFxCvMcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis Kirjanov <kda@linux-powerpc.org> wrote:
> On 1/12/16, Baozeng Ding <sploving1@gmail.com> wrote:
>> If groups is not 0 and nlk->groups is NULL, it will not return
>> immediately and cause a null pointer dereference later.
>>
>> Signed-off-by: Baozeng Ding <sploving1@gmail.com>
>> ---
>> The v3 version adds WARN_ON, suggested by David Miller. Thanks for
>> David's feedback.
> 
> But can you explain how can we get to this situation?

Indeed, this patch makes no sense as it stands.  If groups is
not NULL, then we should have allocated nlk->groups prior to
reaching this point.  If that allocation failed, then we should
have already bailed out long ago.  Perhaps we have a race condition
that needs to be closed with a lock?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
