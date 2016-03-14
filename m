From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v2 0/7] Introduce l3_dev pointer for L3 processing
Date: Sun, 13 Mar 2016 23:53:58 -0400 (EDT)
Message-ID: <20160313.235358.1007563444789525672.davem@davemloft.net>
References: <1457560189-12870-1-git-send-email-mahesh@bandewar.net>
	<20160313.215033.17951850162749485.davem@davemloft.net>
	<CAF2d9jhtvvEdmwP8OrOcUEn+P-Di0TRnjR7-RpcJrKJ3+HAN-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mahesh@bandewar.net, edumazet@google.com, netdev@vger.kernel.org
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbcCNDyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 23:54:01 -0400
In-Reply-To: <CAF2d9jhtvvEdmwP8OrOcUEn+P-Di0TRnjR7-RpcJrKJ3+HAN-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Sun, 13 Mar 2016 19:29:58 -0700

> On Sun, Mar 13, 2016 at 6:50 PM, David Miller <davem@davemloft.net> wrote:
>> It doesn't matter whether doing so or not makes sense.
>>
>> You're going to have to find a way to do both, and also I'm concerned
>> about how you're leaking the source namespace's "stuff" into the
>> destination's.  That's very worrisome to me.
>
> If we add a new mode (e.g. L3s) and preserve current mode as is it,
> then that should address your first concern.

Also, I don't want all of this device translation stuff all over the
place.

Furthermore, when you walk across the ns boundary, that old device has
to disappear.  That's why that is the device assigned to skb->dev.

Please stop pretending that this device switching is ok, it's not.
