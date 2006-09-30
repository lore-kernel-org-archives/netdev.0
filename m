From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 0/3] myri10ge Large Receive Offload
Date: Sat, 30 Sep 2006 23:39:04 +0200
Message-ID: <451EE3F8.20202@myri.com>
References: <451B0541.1030208@myri.com> <451B4F44.60204@garzik.org> <451D9B4C.3020008@myri.com> <20060930093800.GA19549@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:4831 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751987AbWI3VjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 17:39:23 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060930093800.GA19549@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov a =C3=A9crit :
> On Sat, Sep 30, 2006 at 12:16:44AM +0200, Brice Goglin (brice@myri.co=
m) wrote:
>  =20
>> Jeff Garzik a =C3=A9crit :
>>    =20
>>> Brice Goglin wrote:
>>>      =20
>>>> The complete driver code in our CVS actually also supports high-or=
der
>>>> allocations instead of single physical pages since it significantl=
y
>>>> increase the performance. Order=3D2 allows us to receive standard =
frames
>>>> at line rate even on low-end hardware such as an AMD Athlon(tm) 64=
 X2
>>>> Dual Core Processor 3800+ (2.0GHz). Some customer might not care a=
 lot
>>>> about memory fragmentation if the performance is better.
>>>>
>>>> But, since high-order allocations are generally considered a bad i=
dea,
>>>> we do not include the relevant code in the following patch for inc=
lusion
>>>> in Linux. Here, we simply pass order=3D0 to all page allocation ro=
utines.
>>>> If necessary, I could drop the remaining reference to high-order
>>>> (especially replace alloc_pages() with alloc_page()) but I'd rathe=
r
>>>> keep it as is.
>>>>
>>>> If high-order allocations are ever considered OK under some circum=
-
>>>> stances, we could send an additional patch (a module parameter wou=
ld
>>>> be used to switch from single physical pages to high-order pages).
>>>>        =20
>> Any comments about what I was saying about high-order allocations ab=
ove?
>>    =20
>
> It is quite strnage that you see very noticeble speed degradation aft=
er
> switching from higher order to 0 order allocations, could specify whe=
re=20
> observed  bottleneck in network stack is?
>  =20

The bottleneck is not in the network stack, it is simply related to the
number of page allocations that are required. Since we store multiple
fragments in a same page, if MTU=3D1500, we need one 0-order allocation
every 2 fragments, while we need one 2-order allocation every 8
fragments. IIRC, we observed about 20% higher throughput on the receive
side when switching from order=3D0 to order=3D2 (7.5Gbit/s -> 9.3Gbit/s=
 with
roughly the same CPU usage).

Brice

