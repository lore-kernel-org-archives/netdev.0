From: David Miller <davem@davemloft.net>
Subject: Re: netlink & rhashtable status
Date: Wed, 13 May 2015 12:35:20 -0400 (EDT)
Message-ID: <20150513.123520.1301797535605779844.davem@davemloft.net>
References: <20150513062038.GA26944@gondor.apana.org.au>
	<1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
	<1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965101AbbEMQfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 12:35:23 -0400
In-Reply-To: <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 May 2015 09:18:04 -0700

> On Wed, 2015-05-13 at 06:04 -0700, Eric Dumazet wrote:
>> On Wed, 2015-05-13 at 14:20 +0800, Herbert Xu wrote:
>> > On Tue, May 12, 2015 at 11:15:40PM -0700, Eric Dumazet wrote:
>> > > 
>> > > Trick is to start about 200 threads using getaddrinfo()
>> > 
>> > When it loses the kernel socket, is it permanent or intermittent?
>> > 
>> > I'm trying to figure out whether it's the hashtable reader missing
>> > an entry that's there or whether the hashtable has been corrupted
>> > and an entry is gone forever.
>> > 
>> > Cheers,
>> 
>> This is permanent. We have to reboot the host.
>> 
> 
> For 4.0.3 I replaced the two rhashtable files by current Linus version,
> and problem is gone, so the fix is not in net/netlink
> 
>  include/linux/rhashtable.h |   10 
>  lib/rhashtable.c           |  582 ++++++++++++-----------------------
>  2 files changed, 215 insertions(+), 377 deletions(-)
> 
> I did a bisection but ended to 
> 
> 393619474ec0 rhashtable: Fix read-side crash during rehash
> 
> And simply backporting it does not solve the problem

Backporting all of the rhashtable bits is going to be really painful
and potentially quite risky.  However, if someone is confident enough,
I'm willing to entertain this idea.

Alternatively, we could consider reverting the rhashtable conversion
of netlink in the interim.  It might be the safest solution for
-stable.
