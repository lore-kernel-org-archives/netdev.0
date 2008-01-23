From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.25 1/1]S2io: Multiqueue network device support implementation
Date: Wed, 23 Jan 2008 15:48:24 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702E70E92@nekter>
References: <p73odbclsft.fsf@crumb.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"support" <support@neterion.com>
To: "Andi Kleen" <andi@firstfloor.org>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:2396 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751807AbYAWUtz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 15:49:55 -0500
Content-class: urn:content-classes:message
In-Reply-To: <p73odbclsft.fsf@crumb.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com> writes:
> 
> > Multiqueue netwrok device support implementation.
> > - Added a loadable parameter "multiq" to enable/disable multiqueue
> support,
> >   by default it is disabled.
> > - skb->queue_mapping is not used for queue/fifo selection. FIFO
> iselection is
> >   based on IP-TOS value, 0x0-0xF TOS values are mapped to 8 FIFOs.
> 
> Standard way to use that would be using skb->priority
[Ram] Thanks. We can use this field to determine the priority. It should
simplify the code.

> 
> But I'm surprised you bother with TOS for multi queues at all. TOS
> isn't a too important mechanism.
[Ram] Agreed TOS is not too important. The purpose of this patch was to
add the multiqueue functionality with a feature that can use it. With
multiple transmit fifos enabled, a whole new set of features that can be
enabled.

> 
> I would have thought the primary use case would be per CPU TX
completion
> interrupts. With that the queue should be selected based on
> the the current CPU.
> 
[Ram] I am assuming that this is with regards to msi-x interrupts. We
have done away with handling tx completion in the interrupt handler, and
are instead handling them in the context of the transmit. The slow path,
straggling transmit completions will be handled in the timer context.
This patch (along with other new features) will be sent soon.

Ram
> -Andi
