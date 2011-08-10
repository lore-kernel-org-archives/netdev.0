From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] slip: fix NOHZ local_softirq_pending 08 warning
Date: Wed, 10 Aug 2011 10:28:24 +0100
Message-ID: <20110810102824.4c4eaefe@lxorguk.ukuu.org.uk>
References: <CAKh5naYrNPG3UO02VzG13QUP-SOP8-Td+O0G5LAr-+npduP49A@mail.gmail.com>
	<4E416951.4020207@hartkopp.net>
	<CAKh5naayzp3ANwnE2Y9U2LEaiWNoZAuT3aOQbRYdoB5uNdrOPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:41182 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752632Ab1HJJZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 05:25:04 -0400
In-Reply-To: <CAKh5naayzp3ANwnE2Y9U2LEaiWNoZAuT3aOQbRYdoB5uNdrOPw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>   2) From tty_flip_buffer_push() which schedules the flush_to_ldisc to
> work or calls it directly if the tty->low_latency set.
> 
> So the only thing we must take into account that with tty->low_latency
> set we can be in IRQ context when doing with netif_rx_ni(). But if we

A driver is not permitted to directly call into flush_to_ldisc from an
interrupt so that case doesn't happen.

Alan
