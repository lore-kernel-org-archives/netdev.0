From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 11:28:25 -0700
Message-ID: <CAHA+R7MJX3Du8ggOo2GqGA4rXvY30YOpCFqS4PBN2ZNE=kwKuA@mail.gmail.com>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	Daniel Borkmann <dborkman@redhat.com>, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:52574 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964879AbaH0S21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 14:28:27 -0400
Received: by mail-lb0-f175.google.com with SMTP id c11so933348lbj.20
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 11:28:25 -0700 (PDT)
In-Reply-To: <20140825.163458.1117073971092495452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 25, 2014 at 4:34 PM, David Miller <davem@davemloft.net> wrote:
>
> Given Jesper's performance numbers, it's not the way to go.
>
> Instead, go with a signalling scheme via new boolean skb->xmit_more.
>
> This has several advantages:
>
> 1) Nearly trivial driver support, just protect the tail pointer
>    update with the skb->xmit_more check.
>
> 2) No extra indirect calls in the non-deferral cases.
>

First of all, I missed your discussion at kernel summit.

Second of all, I am not familiar with hardware NIC drivers.

But for me, it looks like you are trying to pend some more packets
in a TX queue until the driver decides to flush them all in one shot.
So if that is true, doesn't this mean the latency of first packet pending
in this queue will increase and network traffic will be more bursty for
the receiver??

Also, even if this is a cool feature in hardware driver, doesn't it make
sense to allow users to disable it with ethtool?

It looks like this is still WIP, since no one really sets ->xmit_more to 1
in the code.

Thanks.
