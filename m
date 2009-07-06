From: David Miller <davem@davemloft.net>
Subject: Re: tun netns BUG()
Date: Sun, 05 Jul 2009 19:01:37 -0700 (PDT)
Message-ID: <20090705.190137.148499351.davem@davemloft.net>
References: <m163e9hl8x.fsf@fess.ebiederm.org>
	<20090703152547.GA28755@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, dwmw2@infradead.org, netdev@vger.kernel.org,
	johannes@sipsolutions.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35906
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752126AbZGFCBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 22:01:30 -0400
In-Reply-To: <20090703152547.GA28755@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 3 Jul 2009 23:25:47 +0800

> Eric W. Biederman <ebiederm@xmission.com> wrote:
>> 
>> Not so.
>> 
>> unregister_netdevice
>>  rollback_registered
>>    tun_net_unit
>>      __tun_detach.
>> 
>> 
>> Further we need rtnl_lock around __tun_detach.
> 
> No we don't, tfile->count prevents this from occuring.  The async
> path will only __tun_detach if the count hits zero, in which case
> the first if clause in tun_chr_close will fail.  Conversely, if
> we're in the first if clause in tun_chr_close, then the async
> path either didn't execute at all or did not call __tun_detach.

I've applied Herbert's patch, thanks!
