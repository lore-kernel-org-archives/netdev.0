From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: e100 badness (2.6.10-rc1-mm2)
Date: Mon, 1 Nov 2004 21:05:52 -0800
Message-ID: <468F3FDA28AA87429AD807992E22D07E031BAB39@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Chilakala, Mallikarjuna" <mallikarjuna.chilakala@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Randy.Dunlap" <rddunlap@osdl.org>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Randy:

Thanks for the information. We are aware of this (from a previous
conversation between Scott Feldman, Andrew Morton and Jeremy
Fitzhardinge). We are working on a fix for this.

Thanks,
Ganesh.

>-----Original Message-----
>From: Randy.Dunlap [mailto:rddunlap@osdl.org]
>Sent: Monday, November 01, 2004 8:24 PM
>To: Venkatesan, Ganesh; Brandeburg, Jesse; netdev@oss.sgi.com
>Subject: e100 badness (2.6.10-rc1-mm2)
>
>Hi Ganesh, Jesse --
>
>I see this in 2.6.10-rc1-mm2:
>
>Badness in enable_irq at kernel/irq/manage.c:112
>   [<c0106e09>] dump_stack+0x1e/0x20
>   [<c013f7ab>] enable_irq+0xaa/0x114
>   [<c02b0498>] e100_up+0x130/0x23f
>   [<c02b164a>] e100_open+0x26/0x6e
>   [<c0396896>] dev_open+0x6e/0x7c
>   [<c0397e05>] dev_change_flags+0x56/0x126
>   [<c03d2426>] devinet_ioctl+0x60b/0x6cd
>   [<c03d4261>] inet_ioctl+0x81/0xae
>   [<c038ddbc>] sock_ioctl+0x1d3/0x2d6
>   [<c0172970>] sys_ioctl+0x179/0x21d
>   [<c0105f5d>] sysenter_past_esp+0x52/0x71
>
>
>I think that it happens because (in e100_up()),
>disable_irq() is called before request_irq() is called.
>If there are no other interrupt handlers on the same irq,
>then desc->depth is cleared to 0 by setup_irq() [called
>from request_irq()].
>Then the following enable_irq() is confused by
>desc->depth == 0.
>
>--
>~Randy
