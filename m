From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: tun always return NETDEV_TX_OK, why?
Date: Tue, 13 Aug 2013 10:33:31 -0700
Message-ID: <20130813103331.20946af6@nehalam.linuxnetplumber.net>
References: <CAJ4BwwEbBQQ=S5pd=8rHAxnOm-P7yQPv9q2D7c1D9cVh5ArAPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yannick Koehler <yannick@koehler.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:55928 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758896Ab3HMRdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 13:33:35 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so5223631pde.37
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 10:33:35 -0700 (PDT)
In-Reply-To: <CAJ4BwwEbBQQ=S5pd=8rHAxnOm-P7yQPv9q2D7c1D9cVh5ArAPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Aug 2013 10:39:02 -0400
Yannick Koehler <yannick@koehler.name> wrote:

> Hello,
> 
>   I hit a problem recently with the tun interface, it looks like when
> this interface reach its txqueuelen it will then drop the packet and
> return NETDEV_TX_OK unconditionally.
> 
>  That, from my little understanding of the netdev framework, appears
> to be wrong and will simply eat up any pending buffer and discard them
> until the queue frees itself.  That seems to be against the flow
> control design in the tx queue system of the kernel.
> 
>   So, is this a bug or a misunderstanding?  Would it be ok for tun to
> return NETDEV_TX_BUSY when the txqueuelen is reach and call
> netif_stop_queue() so that the layer above stop sending frame to this
> interface until it can cope it's current queue content?
> 

NETDEV_TX_BUSY won't work well for this because it basically
causes kernel to spin waiting for the transmit queue.
A better way is to figure out how to do proper flow control
with start/stop queue.
