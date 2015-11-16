From: David Miller <davem@davemloft.net>
Subject: Re: irq_fpu_usable() is false in ndo_start_xmit() for UDP packets
Date: Mon, 16 Nov 2015 15:32:14 -0500 (EST)
Message-ID: <20151116.153214.1125103075112383723.davem@davemloft.net>
References: <CAHmME9qQz-uTFDjUuVaqpO9ODt3KZWEdYVQJ8qsXWa5YkYAoWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason@zx2c4.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9qQz-uTFDjUuVaqpO9ODt3KZWEdYVQJ8qsXWa5YkYAoWA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Mon, 16 Nov 2015 20:52:28 +0100

> This works fine with, say, iperf3 in TCP mode. The AVX performance
> is great. However, when using iperf3 in UDP mode, irq_fpu_usable()
> is mostly false! I added a dump_stack() call to see why, except
> nothing looks strange; the initial call in the stack trace is
> entry_SYSCALL_64_fastpath. Why would irq_fpu_usable() return false
> when we're in a syscall? Doesn't that mean this is in process
> context?

Network device driver transmit executes with software interrupts
disabled.

Therefore on x86, you cannot use the FPU.
