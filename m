From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: what is the use of poll function int a net_device struct
Date: Tue, 15 Jan 2013 15:20:39 +0200
Message-ID: <CAKoUArmq0+aMdMyDvRu+fCJXynrqywpeJiajG=84YCxdFV-GKg@mail.gmail.com>
References: <20130114142136.GA17094@debian.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: horseriver <horserivers@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:37854 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755778Ab3AONUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 08:20:39 -0500
Received: by mail-qa0-f49.google.com with SMTP id r4so146644qaq.8
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 05:20:39 -0800 (PST)
In-Reply-To: <20130114142136.GA17094@debian.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Jan 14, 2013 at 4:21 PM, horseriver <horserivers@gmail.com> wrote:
> Where is the handler function defined  for an netcard's  IRQ

look for the request_irq() method; you register the handler with this method.

for example,
in e1000e:

http://lxr.free-electrons.com/source/drivers/net/ethernet/intel/e1000e/netdev.c

err = request_irq(adapter->msix_entries[vector].vector,
                           e1000_intr_msix_rx, 0,
                          adapter->rx_ring->name,
                             netdev);

so the handler is   e1000_intr_msix_rx().

When an IRQ has reached,  how to wake_up the wait_queue of the socket?
TCP/UDP packet goes up from the driver to L3 and then to L4 (in case
it is for this machine). In L4 you should find the
wake_up of the wait_queue of the socket.

Regards,
Rami Rosen
http://ramirose.wix.com/ramirosen
