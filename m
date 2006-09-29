From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 0/3] myri10ge Large Receive Offload
Date: Sat, 30 Sep 2006 00:16:44 +0200
Message-ID: <451D9B4C.3020008@myri.com>
References: <451B0541.1030208@myri.com> <451B4F44.60204@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:47855 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1750808AbWI2WTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 18:19:54 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <451B4F44.60204@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik a =E9crit :
> Brice Goglin wrote:
>> This is a complete rework of the myri10ge receive path. The first
>> patch converts skb allocation to use physical pages. The second one
>> adds a software implementation of Large Receive Offload. The third
>> one updates the driver version to 1.1.0.
>>
>> The complete driver code in our CVS actually also supports high-orde=
r
>> allocations instead of single physical pages since it significantly
>> increase the performance. Order=3D2 allows us to receive standard fr=
ames
>> at line rate even on low-end hardware such as an AMD Athlon(tm) 64 X=
2
>> Dual Core Processor 3800+ (2.0GHz). Some customer might not care a l=
ot
>> about memory fragmentation if the performance is better.
>>
>> But, since high-order allocations are generally considered a bad ide=
a,
>> we do not include the relevant code in the following patch for inclu=
sion
>> in Linux. Here, we simply pass order=3D0 to all page allocation rout=
ines.
>> If necessary, I could drop the remaining reference to high-order
>> (especially replace alloc_pages() with alloc_page()) but I'd rather
>> keep it as is.
>>
>> If high-order allocations are ever considered OK under some circum-
>> stances, we could send an additional patch (a module parameter would
>> be used to switch from single physical pages to high-order pages).
>
> As Herbert's already done, I would rather let the net core people
> comment on this.  The code implementation doesn't look scary, but we
> may want to be smarter about this in the core net stack, rather than
> implementing it inside multiple drivers.

Ok, makes sense. We look forward to see this.

Could we get patch #1 merged anyway (page-based skb allocation)?

Any comments about what I was saying about high-order allocations above=
?

thanks,
Brice

