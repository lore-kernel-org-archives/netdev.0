From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Fri, 27 Jul 2012 18:28:53 +0200
Message-ID: <1343406533.2626.13104.camel@edumazet-glaptop>
References: <20120726.155327.947597248143903676.davem@davemloft.net>
	 <CAKgT0UdhqDQSFZkWw9w8L2qsCS+MM_DLQE+Vq0mKcYZmxhs=8Q@mail.gmail.com>
	 <20120726.200846.66786272076299783.davem@davemloft.net>
	 <20120726.230246.219188476590178857.davem@davemloft.net>
	 <1343383283.2626.12691.camel@edumazet-glaptop>
	 <87boj15k8c.fsf@xmission.com>
	 <1343401949.2626.13011.camel@edumazet-glaptop>
	 <87mx2l41hl.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alexander.duyck@gmail.com,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34167 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab2G0Q26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 12:28:58 -0400
Received: by bkwj10 with SMTP id j10so2009308bkw.19
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 09:28:57 -0700 (PDT)
In-Reply-To: <87mx2l41hl.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-27 at 09:23 -0700, Eric W. Biederman wrote:

> I am familiar.  But does hardware prefetching make a difference
> if your object is less than 64 bytes?
> 

Apparently yes, if the prefetch touches a dirtied neighbour cache line.

> I don't believe only allocating 64 bytes will be a problem,
> as no one else well be dirtying your cache line.
> 
> I suppose you could run into pathologies where your object
> is 3*64 bytes in size, but your expression doesn't handle
> that case either.
> 

Sure, but in most cases fib objects are under 128 bytes.


> The other alternative to guarantee very good cache behavior is
> to ensure you are allocating a power of two size up to some limit,
> perhaps page size.
> 

Good idea.

> My point is the magic 128 likely requires an explicatory comment and I
> think the net result is you have encoded something fragile that is good
> for testing but that will in the fullness of time do strange things that
> will be easy to overlook.

Sure, I'll send a v2, thanks.
