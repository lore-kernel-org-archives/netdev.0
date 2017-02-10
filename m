From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: mkiss: Fix panic
Date: Fri, 10 Feb 2017 13:42:00 -0500 (EST)
Message-ID: <20170210.134200.637935062739586183.davem@davemloft.net>
References: <B4836AA3-200E-4BDA-B1B1-CD3F6AF28F94@osterried.de>
        <20170209131211.GA16072@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, thomas@osterried.de
To: ralf@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170209131211.GA16072@linux-mips.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Thu, 9 Feb 2017 14:12:11 +0100

> If a USB-to-serial adapter is unplugged, the driver re-initializes, with
> dev->hard_header_len and dev->addr_len set to zero, instead of the correct
> values.  If then a packet is sent through the half-dead interface, the
> kernel will panic due to running out of headroom in the skb when pushing
> for the AX.25 headers resulting in this panic:
> 
> [<c0595468>] (skb_panic) from [<c0401f70>] (skb_push+0x4c/0x50)
> [<c0401f70>] (skb_push) from [<bf0bdad4>] (ax25_hard_header+0x34/0xf4 [ax25])
> [<bf0bdad4>] (ax25_hard_header [ax25]) from [<bf0d05d4>] (ax_header+0x38/0x40 [mkiss])
> [<bf0d05d4>] (ax_header [mkiss]) from [<c041b584>] (neigh_compat_output+0x8c/0xd8)
> [<c041b584>] (neigh_compat_output) from [<c043e7a8>] (ip_finish_output+0x2a0/0x914)
> [<c043e7a8>] (ip_finish_output) from [<c043f948>] (ip_output+0xd8/0xf0)
> [<c043f948>] (ip_output) from [<c043f04c>] (ip_local_out_sk+0x44/0x48)
> 
> This patch makes mkiss behave like the 6pack driver. 6pack does not
> panic.  In 6pack.c sp_setup() (same function name here) the values for
> dev->hard_header_len and dev->addr_len are set to the same values as in
> my mkiss patch.
> 
> [ralf@linux-mips.org: Massages original submission to conform to the usual
> standards for patch submissions.]
> 
> Signed-off-by: Thomas Osterried <thomas@osterried.de>
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thank you.
