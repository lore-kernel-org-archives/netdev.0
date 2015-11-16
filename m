From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: irq_fpu_usable() is false in ndo_start_xmit() for UDP packets
Date: Mon, 16 Nov 2015 23:27:10 +0100
Message-ID: <1447712830.2096939.441563921.3680DBCF@webmail.messagingengine.com>
References: <CAHmME9qQz-uTFDjUuVaqpO9ODt3KZWEdYVQJ8qsXWa5YkYAoWA@mail.gmail.com>
 <20151116.153214.1125103075112383723.davem@davemloft.net>
 <CAHmME9o3s5iTZ4gcFVQ1xTu9PaaLjkEGcvhJRF+S=0GugxhQ8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:55239 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751361AbbKPW1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 17:27:11 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 3239720A24
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 17:27:11 -0500 (EST)
In-Reply-To: <CAHmME9o3s5iTZ4gcFVQ1xTu9PaaLjkEGcvhJRF+S=0GugxhQ8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jason,

On Mon, Nov 16, 2015, at 21:58, Jason A. Donenfeld wrote:
> Hi David,
> 
> On Mon, Nov 16, 2015 at 9:32 PM, David Miller <davem@davemloft.net>
> wrote:
> > Network device driver transmit executes with software interrupts
> > disabled.
> >
> > Therefore on x86, you cannot use the FPU.
> 
> That is extremely problematic for me. Is there a way to make this not
> so? A driver flag that would allow this?
> 
> Also - how come it irq_fpu_usable() is true when using TCP but not
> when using UDP?
> 
> Further, irq_fpu_usable() doesn't only check for interrupts. There are
> two other conditions that allow the FPU's usage, from
> arch/x86/kernel/fpu/core.c:
> 
> bool irq_fpu_usable(void)
> {
>         return !in_interrupt() ||
>                 interrupted_user_mode() ||
>                 interrupted_kernel_fpu_idle();
> }

Use the irqsoff tracer to find the problematic functions which disable
interrupts and try to work around it in case of UDP. This could benefit
the whole stack.

Bye,
Hannes
