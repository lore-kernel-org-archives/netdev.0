From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: Re: [RFC/PATCH 3/3] UDP memory usage accounting (take 2): measurement
Date: Mon, 01 Oct 2007 22:52:27 +0900
Message-ID: <4700FB9B.1060304@hitachi.com>
References: <46FD048B.9010409@hitachi.com> <20070928143710.GA16747@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev <netdev@vger.kernel.org>,
	=?windows-1252?Q?=3F=3F_=3F=3F?= <yoshfuji@linux-ipv6.org>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	=?windows-1252?Q?=22=3F=3F=40RedHat=22?= <haoki@redhat.com>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:39341 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161AbXJANwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 09:52:33 -0400
Received: from mlsv16.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id C2A5B37ADE
	for <netdev@vger.kernel.org>; Mon,  1 Oct 2007 22:52:31 +0900 (JST)
In-Reply-To: <20070928143710.GA16747@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Fri, Sep 28, 2007 at 10:41:31PM +0900, Satoshi OSHIMA
(satoshi.oshima.fk@hitachi.com) wrote:
>> This patch introduces memory usage measurement for UDP.
>>
>> These 3 points were updated.
>>
>> - UDP specific codes in IP layer were removed.
>>
>> - atomic_sub() in a loop was removed
>>
>> - accounting during socket destruction
>
> Another approach is to account only at the highest UDP layer and having
> datagram skb destructor just like it is done in TCP, but this approach
> is also resonable.


This patch set try to introduce a memory accounting by the page
because TCP does. And ip_append_data() merges payloads to a sk_buff
if previous sk_buff has enough space. The problem is that
udp_append_data() doesn't recognize whether this merge happens or not.

If the accounting must be in UDP layer, we need to change
the interface of ip_append_data() to know this merge happens.

Once the interface is changed, we have to maintain other
protocol stacks to keep up with the change.

But I didn't want to do it to keep this patch set small
in the first step.


> I already told that patches 1 and 3 have broken indent, please fix that.

Oops! I will fix that.


> A hint: when you are about to submit something network related for
inclusion,
> and strongly believes it is ready, it can be a not that bad idea to add
> David Miller <davem@davemloft.net> to copy list, he can complain about
> backlog and so on, but will read you mail twice :) but do not tell anyone.

Thank you for your advice. I will do that!

Satoshi Oshima
