From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2.6.25 1/1]S2io: Multiqueue network device support implementation
Date: 23 Jan 2008 11:58:14 +0100
Message-ID: <p73odbclsft.fsf@crumb.suse.de>
References: <Pine.GSO.4.10.10801221942530.24414-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35164 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536AbYAWK6S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 05:58:18 -0500
In-Reply-To: <Pine.GSO.4.10.10801221942530.24414-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com> writes:

> Multiqueue netwrok device support implementation.
> - Added a loadable parameter "multiq" to enable/disable multiqueue support,
>   by default it is disabled.
> - skb->queue_mapping is not used for queue/fifo selection. FIFO iselection is
>   based on IP-TOS value, 0x0-0xF TOS values are mapped to 8 FIFOs.

Standard way to use that would be using skb->priority

But I'm surprised you bother with TOS for multi queues at all. TOS
isn't a too important mechanism.

I would have thought the primary use case would be per CPU TX completion
interrupts. With that the queue should be selected based on
the the current CPU.

-Andi
