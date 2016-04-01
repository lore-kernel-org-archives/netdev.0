From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH 3/4] net: w5100: enable to support sleepable register
 access interface
Date: Sat, 2 Apr 2016 01:42:44 +0900
Message-ID: <CAC5umyhHw6wR=g7wQTH8ouZ8HA9+7ww4=AVf=AiCwD9J2CFQ9Q@mail.gmail.com>
References: <1459355920-14623-1-git-send-email-akinobu.mita@gmail.com>
	<1459355920-14623-3-git-send-email-akinobu.mita@gmail.com>
	<20160331.153040.1786802199114216613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Mike Sinkovsky <msink@permonline.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34061 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbcDAQmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 12:42:45 -0400
Received: by mail-yw0-f195.google.com with SMTP id f6so20267723ywa.1
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 09:42:44 -0700 (PDT)
In-Reply-To: <20160331.153040.1786802199114216613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-04-01 4:30 GMT+09:00 David Miller <davem@davemloft.net>:
> From: Akinobu Mita <akinobu.mita@gmail.com>
> Date: Thu, 31 Mar 2016 01:38:39 +0900
>
>> +     struct sk_buff_head tx_queue;
>
> The way the queueing works in this driver is that it is only possible
> to have one SKB being transmitted at one time.
>
> This is evident by how the driver immediately stops the TX queue when
> it is given a new packet to transmit, and this is woken up by the TX
> completion IRQ.
>
> So don't use a queue here, just use a plain single pointer.
>
> The SKB queue you're using here is going to also do locking which is
> even more unnecessary overhead.

Thanks for spotting this.  Using a single pointer works fine.

Maybe we can support sending multiple packets at a time, but it should be
another separated patch.
