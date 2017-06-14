From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH] via-rhine: add support for changing MTU
Date: Wed, 14 Jun 2017 15:02:30 +0900
Message-ID: <CANqRtoQ705E_aAVazOOphZAFPBk6gdOq=umROnM+0ove9Y0j7A@mail.gmail.com>
References: <149737430797.28477.9215445312169809396.sendpatchset@little-apple> <20170613.173318.167061176274123943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613.173318.167061176274123943.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 14, 2017 at 6:33 AM, David Miller <davem@davemloft.net> wrote:
> From: Magnus Damm <magnus.damm@gmail.com>
> Date: Wed, 14 Jun 2017 02:18:27 +0900
>
>> From: Magnus Damm <damm+renesas@opensource.se>
>>
>> Allow adjusting the MTU for via-rhine devices in case of no TX alignment
>> buffer is used.
>>
>> Lightly tested on ALIX2D13 hardware by making use of VXLAN with MTU set
>> to 1500 on top of via-rhine devices with 1550 MTU. Without this patch
>> the VXLAN MTU is limited to less than 1500.
>>
>> Signed-off-by: Magnus Damm <damm+renesas@opensource.se>
>
> Why is the TX alignment buffer such an obstacle?

Not such a big obstacle - I simply took the easy way out for this
first step. Adding support for MTU configuration when TX alignment is
required requires a bit more effort, and it also makes the driver
implementation slightly more complex.

The particular silicon version of via-rhine devices on my ALIX2D13
boards do not require the TX alignment workaround, but I should be
able to add some local test code for development purpose.

As for the TX alignment workaround implementation, when needed the
driver allocates rp->tx_bufs to PKT_BUF_SIZE * TX_RING_SIZE. To
support a larger MTU setting without increasing default memory usage
this TX side can be adjusted to manage buffers in a more dynamic way,
perhaps similar to the RX side with rp->rx_buf_sz.

> It would be so much nicer if this could be supported for all chip
> variants instead of some certain subset which users have no idea
> of figuring out.  It's a really bad user experience to set them
> up for failure like this.

Sure, I agree!

Will update the code with the TX alignment workaround and resend after
some much needed testing. It will most likely take some time, so
please don't block anything on this.

Cheers,

/ magnus
