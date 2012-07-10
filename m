From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Tue, 10 Jul 2012 22:22:45 +0800
Message-ID: <CACVXFVPmec5_3Up9qM4iA90Xua9J_E-aRT-2g7Hu7TR4zRKQtA@mail.gmail.com>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	<1341474192.2583.3299.camel@edumazet-glaptop>
	<CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	<1341477192.2583.3415.camel@edumazet-glaptop>
	<CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	<1341481760.2583.3579.camel@edumazet-glaptop>
	<CACVXFVNYwNrdWS_EiQ4O0-ou369AQ2tB4qbvmzY1rt5T3QnyUw@mail.gmail.com>
	<1341842043.3265.2914.camel@edumazet-glaptop>
	<CACVXFVNdiwVn1Mo--N4N0HdYrEJizExtd_cppT4tS=mjog2PKw@mail.gmail.com>
	<1341895143.3265.4049.camel@edumazet-glaptop>
	<CACVXFVPgqtSN3BrEXRxSv4yxaxCni495SxZNXBmYQpagmxk2tQ@mail.gmail.com>
	<1341908908.3265.4508.camel@edumazet-glaptop>
	<CACVXFVM-fhQJX+EFNoFSnuVAjqfRM7OjzbQML7H+tMEjxG7Rug@mail.gmail.com>
	<1341928931.3265.5263.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:47470 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195Ab2GJOWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 10:22:50 -0400
Received: by obbuo13 with SMTP id uo13so20504obb.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 07:22:50 -0700 (PDT)
In-Reply-To: <1341928931.3265.5263.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 10, 2012 at 10:02 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> I am kind of annoyed you sent on netdev a copy of a _private_ mail.

I am sure that your reply which includes below is not from a private mail:

       Only because skbs were fat (8KB allocated/truesize, for a single
       1500 bytes frame)

>
> Next time, make sure you dont do that without my consent.

OK

> On Tue, 2012-07-10 at 21:37 +0800, Ming Lei wrote:
>
>> Could you explain why the truesize of SKB is 8KB for single
>> 1500bytes frame?
>>
>
> Because the driver uses skb_alloc(4096) for example ?
>
> I don't know, you don't tell us the driver.
>
>
> Goal is to have skb->head points to a 2048 bytes area, so truesize
> should be 2048 + sizeof(sk_buff)  (including struct shared_info)
>
>> I observed it is 2560bytes for RX SKBs inside asix_rx_fixup with
>> rx_urb_size of 2048 on beagle-xm.
>>
>
> Thats because using 2048 bytes for the urb buffer (excluding
> shared_info) means you need :
>
> 2048 + sizeof(struct shared_info) + sizeof(sk_buff) = 2560
>
> In fact 2048 + sizeof(struct shared_info) means a full 4096 area is
> used.
>
> You have 2560 on recent kernels because the way netdev_alloc_frag()
> works.
>
> Thats why copybreak can actually saves ram. Since it is adding a copy,
> we try to use it only on slow devices.

Looks single page allocation won't put too much pressure on MM, that is
why I suggested to avoid copy if the skb buffer size is less or equal one
page. Anyway, unnecessary copy will increase computation and consume power.


Thanks,
-- 
Ming Lei
