From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: irq_fpu_usable() is false in ndo_start_xmit() for UDP packets
Date: Mon, 16 Nov 2015 21:58:49 +0100
Message-ID: <CAHmME9o3s5iTZ4gcFVQ1xTu9PaaLjkEGcvhJRF+S=0GugxhQ8Q@mail.gmail.com>
References: <CAHmME9qQz-uTFDjUuVaqpO9ODt3KZWEdYVQJ8qsXWa5YkYAoWA@mail.gmail.com>
	<20151116.153214.1125103075112383723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151116.153214.1125103075112383723.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Mon, Nov 16, 2015 at 9:32 PM, David Miller <davem@davemloft.net> wrote:
> Network device driver transmit executes with software interrupts
> disabled.
>
> Therefore on x86, you cannot use the FPU.

That is extremely problematic for me. Is there a way to make this not
so? A driver flag that would allow this?

Also - how come it irq_fpu_usable() is true when using TCP but not
when using UDP?

Further, irq_fpu_usable() doesn't only check for interrupts. There are
two other conditions that allow the FPU's usage, from
arch/x86/kernel/fpu/core.c:

bool irq_fpu_usable(void)
{
        return !in_interrupt() ||
                interrupted_user_mode() ||
                interrupted_kernel_fpu_idle();
}
