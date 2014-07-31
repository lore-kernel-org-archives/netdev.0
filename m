From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2] netfilter: nf_sockopt_find() / nf_register_sockopt() should not return EINTR
Date: Thu, 31 Jul 2014 12:05:53 +0100
Message-ID: <e0634e99-e1e9-47b7-9a99-1f053d66e2f0@email.android.com>
References: <1406155995.3363.19.camel@edumazet-glaptop2.roam.corp.google.com> <3ff5bf70-5db3-4dc4-9f02-abb07843ab81@email.android.com> <1406234495.3363.79.camel@edumazet-glaptop2.roam.corp.google.com> <20140731105525.GA4680@salvia>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44950 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbaGaLGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 07:06:05 -0400
In-Reply-To: <20140731105525.GA4680@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31. Juli 2014 11:55:25 GMT+01:00, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>On Thu, Jul 24, 2014 at 10:41:35PM +0200, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> getsockopt() or setsockopt() sometimes returns -EINTR instead of
>> -ENOPROTOOPT, causing headaches to application developers.
>> 
>> This is because unsupported commands might go through
>nf_sockopt_find()
>> and this function returns -EINTR if a signal is pending.
>> 
>> Just use non interruptible mutex functions, as there is no reason
>> we should sleep for a long time here.
>
>On top of this patch, I think that at least we can also ged rid of
>these interruptible mutex from the netfilter/core code too (see
>preliminary patch attached).

Agreed. I think there are actually no cases at all where using the
interruptable variants makes sense.

>I can also adapt the callers so they don't check anymore the return
>value as they will always succeed.
>
>Comments? Thanks.

I'd leave checks in the callers at least for all init/registration functions.
Quite possible future changes will add back error conditions and its
more consistent to follow this convention in all cases.
