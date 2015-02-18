From: Cong Wang <cwang@twopensource.com>
Subject: Re: Why do we use RX queue mapping for TX?
Date: Wed, 18 Feb 2015 13:18:13 -0800
Message-ID: <CAHA+R7PdG+jDqFA1jDFzHtkrxqLEZdtj1w5QyrdYMO4fX6+A1w@mail.gmail.com>
References: <CAHA+R7MXF-KHZ3aeBwwshSYDswKwrjhbMJQ=+Hfj3gZJq70dXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:44176 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433AbbBRVSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 16:18:14 -0500
Received: by iecar1 with SMTP id ar1so4622518iec.11
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 13:18:13 -0800 (PST)
In-Reply-To: <CAHA+R7MXF-KHZ3aeBwwshSYDswKwrjhbMJQ=+Hfj3gZJq70dXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David

With regarding to the following commit:

commit d5a9e24afb4ab38110ebb777588ea0bd0eacbd0a
Author: David S. Miller <davem@davemloft.net>
Date:   Tue Jan 27 16:22:11 2009 -0800

    net: Allow RX queue selection to seed TX queue hashing.

What's the point of this commit? It looks like it is for routers
where skb->queue_mapping is preserved across forwarding.
Or some software interface, but they usually don't even have
a queue.

But:

1) the incoming interface may not be same with the outgoing
interface, therefore they may not has the same number of queues.
Even if it's the same interface, the number of RX queues doesn't
have to be same with TX queues either.

2) This breaks the queue mapping specified by an skbedit action,
since for TX queues the index starts with 0 while for RX it starts with 1
(for some reason I don't see yet). There is at least a mismatch.

3) Since both TX and RX use the same field ->queue_mapping,
I assume normally it is supposed to be set and used only by one of them,
so the above commit kinda breaks this too.

Or am I still missing anything?

Thanks!
