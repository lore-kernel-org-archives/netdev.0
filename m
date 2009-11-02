From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] multiqueue changes
Date: Mon, 2 Nov 2009 12:30:29 +0000
Message-ID: <20091102123029.GA7790@ff.dom.local>
References: <20091030100033.GA6150@ff.dom.local> <1257009952.9706.30.camel@HP1> <20091101132017.GA2598@ami.dom.local> <20091102.033533.08766686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, kaber@trash.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:36199 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754674AbZKBMa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 07:30:27 -0500
Received: by bwz27 with SMTP id 27so6239678bwz.21
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 04:30:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091102.033533.08766686.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 02, 2009 at 03:35:33AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 1 Nov 2009 14:20:17 +0100
> 
> > There is a question if we can predict in ->probe() MSI-X should be
> > successfully enabled in ->ndo_open() for probed hardware. If so,
> > then it could go e.g. like this:
> 
> We never can know this.
> 
> Another device driver can eat up all the MSI-X vectors in the PCI
> domain before we make the request_irq() calls in ->open().

Right, but it's not a 50% chance, I guess? A user most of the time
gets consistently multiqueue or non-multiqueue behavior after open,
unless I miss something. Then such an exceptional state could be
handled by real_num_tx_queues (just like in case of powered of cpus).
The main difference is to hold in num_tx_queues something that is
really available vs max possible value for all configs.

Jarek P. 
