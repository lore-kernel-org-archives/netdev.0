From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [PATCH] net: macb: Write only necessary bits in NCR in macb reset
Date: Wed, 30 Nov 2016 09:47:22 +0530
Message-ID: <CAFcVECJtjV_jvrZi9Kc=hrMs9u_vKUGHgv5HeROSj=vCmOxNPQ@mail.gmail.com>
References: <1480325029-39224-1-git-send-email-harinik@xilinx.com> <20161129.190526.1414678491662084583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Harini Katakam <harini.katakam@xilinx.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "michals@xilinx.com" <michals@xilinx.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161129.190526.1414678491662084583.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Wed, Nov 30, 2016 at 5:35 AM, David Miller <davem@davemloft.net> wrote:
> From: Harini Katakam <harini.katakam@xilinx.com>
> Date: Mon, 28 Nov 2016 14:53:49 +0530
>
>> In macb_reset_hw, use read-modify-write to disable RX and TX.
>> This way exiting settings and reserved bits wont be disturbed.
>> Use the same method for clearing statistics as well.
>>
>> Signed-off-by: Harini Katakam <harinik@xilinx.com>
>
> This doesn't make much sense to me.
>
> Consider the two callers of this function.
>
> macb_init_hw() is going to do a non-masking write to the NCR
> register:
>
>         /* Enable TX and RX */
>         macb_writel(bp, NCR, MACB_BIT(RE) | MACB_BIT(TE) | MACB_BIT(MPE));
>
> So obviously no other writable fields matter at all for programming
> the chip properly, otherwise macb_init_hw() would "or" in the bits
> after a read of NCR.  But that's not what this code does, it
> writes "RE | TE | MPE" directly.
>
> And the other caller is macb_close() which is shutting down the
> chip so can zero out all the other bits and it can't possibly
> matter, also due to the assertion above about macb_init_hw()
> showing that only the RE, TE, and MPE bits matter for proper
> functioning of the chip.
>
> You haven't shown a issue caused by the way the code works now, so
> this patch isn't fixing a bug.  In fact, the "bit preserving" would
> even be misleading to someone reading the code.  They will ask
> themselves what bits need to be preserved, and as shown above none of
> them need to be.
>
> I'm not applying this, sorry.
>

Thanks for the detailed analysis.
I noticed an issue with respect to management port enable bit
when working on the patch series for macb mdio driver for
multi MAC - multi PHY access via same mdio bus.
MPE bit of the MAC (whose phy management register
is used) was being reset. But that is a separate
series still in review.
You are right, there is no existing bug that this
patch addresses. I will come back to this later if
required.

Regards,
Harini
