From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2 net-next] net: Functions to report space available in
 device TX queues
Date: Tue, 26 Aug 2014 08:44:10 -0700
Message-ID: <CA+mtBx-KD6Yw=Bkeb39FPRxUiG4koxSFqGzP_1bViEUf+tj-sw@mail.gmail.com>
References: <alpine.DEB.2.02.1408250823440.31745@tomh.mtv.corp.google.com>
	<20140825.173325.723351409734098574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:46169 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbaHZPoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 11:44:11 -0400
Received: by mail-ig0-f172.google.com with SMTP id h15so4709962igd.5
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 08:44:10 -0700 (PDT)
In-Reply-To: <20140825.173325.723351409734098574.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 25, 2014 at 5:33 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Mon, 25 Aug 2014 08:27:56 -0700 (PDT)
>
>> This patch adds netdev_tx_avail_queue and netdev_avail_queue which are
>> used to report number of bytes available in transmit queues per BQL. The
>> functions call dql_avail which returns BQL limit minus number of
>> inflight bytes. These functions can be called without txlock, for
>> instance to ascertain how much data should be dequeued from a qdisc in
>> a batch. When called without the tx_lock, the result is technically a
>> hint, subsequently when the tx_lock is done for a transmit it is
>> possible the availability has changed (for example a transmit
>> completion may have freed up more space in the queue or changed the
>> limit).
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>
> Ok this looks fine, but could you please resubmit this alongside
> the first use case?
>
It should be called when determining the best size for a transmit
batch, e.g. how many bytes to dequeue from qdisc on wakeup.

> Thanks.
