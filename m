From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] macvlan: allow to enqueue broadcast pkt on virtual device
Date: Fri, 19 Sep 2014 14:24:55 -0700
Message-ID: <CAHA+R7OQ=R8Y0LDVormukRjdosODiRuGq+NTrZQ08sXvfJYUnQ@mail.gmail.com>
References: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:50680 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757845AbaISVY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:24:57 -0400
Received: by mail-lb0-f178.google.com with SMTP id z12so1341920lbi.37
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 14:24:56 -0700 (PDT)
In-Reply-To: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014 at 1:08 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Since commit 412ca1550cbe ("macvlan: Move broadcasts into a work queue"), the
> driver uses tx_queue_len of the master device as the limit of packets enqueuing.
> Problem is that virtual drivers have this value set to 0, thus all broadcast
> packets were rejected.
> Because tx_queue_len was arbitrarily chosen, I replace it with a static limit
> of 1000 (also arbitrarily chosen).
>

Hmm, why not manually set this tx_queue_len to fix it?

At least fifo qdisc also uses tx_queue_len, and when you bond
you have to set it to non-zero.

I am not saying using this tx_queue_len is absolutely correct,
I am saying it may be expected to set tx_queue_len by yourself.
