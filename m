From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v4 net-next] net: Implement fast csum_partial for x86_64
Date: Sat, 27 Feb 2016 00:30:07 -0800
Message-ID: <CAKgT0UdxdY5VF5OzC+W0Y31CcK0T3ffkcRMQrZqJ==L9SdtNuQ@mail.gmail.com>
References: <1456516995-3471163-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Peter Anvin <hpa@zytor.com>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33226 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751841AbcB0IaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 03:30:08 -0500
Received: by mail-ig0-f174.google.com with SMTP id y8so52947693igp.0
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2016 00:30:08 -0800 (PST)
In-Reply-To: <1456516995-3471163-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +{
> +       asm("lea 40f(, %[slen], 4), %%r11\n\t"
> +           "clc\n\t"
> +           "jmpq *%%r11\n\t"
> +           "adcq 7*8(%[src]),%[res]\n\t"
> +           "adcq 6*8(%[src]),%[res]\n\t"
> +           "adcq 5*8(%[src]),%[res]\n\t"
> +           "adcq 4*8(%[src]),%[res]\n\t"
> +           "adcq 3*8(%[src]),%[res]\n\t"
> +           "adcq 2*8(%[src]),%[res]\n\t"
> +           "adcq 1*8(%[src]),%[res]\n\t"
> +           "adcq 0*8(%[src]),%[res]\n\t"
> +           "nop\n\t"
> +           "40: adcq $0,%[res]"
> +                   : [res] "=r" (sum)
> +                   : [src] "r" (buff),
> +                     [slen] "r" (-((unsigned long)(len >> 3))), "[res]" (sum)
> +                   : "r11");
> +

With this patch I cannot mix/match different length checksums without
things failing.  In perf the jmpq in the loop above seems to be set to
a fixed value so perhaps it is something in how the compiler is
interpreting the inline assembler.

- Alex
