From: Tabi Timur-B04825 <B04825@freescale.com>
Subject: Re: [PATCH 6/7] fsl_pmc: Add API to enable device as wakeup event
 source
Date: Sat, 5 Nov 2011 00:08:24 +0000
Message-ID: <CAOZdJXXB9zJWqC+kPq7ZDdzePtp8XNBnWcf5UmE8Ye50U-G7Dg@mail.gmail.com>
References: <1320410349-14600-1-git-send-email-chenhui.zhao@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	Li Yang-R58472 <r58472@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Zhao Chenhui-B35336 <B35336@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:11841
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751747Ab1KEAIk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 20:08:40 -0400
In-Reply-To: <1320410349-14600-1-git-send-email-chenhui.zhao@freescale.com>
Content-Language: en-US
Content-ID: <04AD0AE3E3676645AFF176EA30732915@freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 4, 2011 at 7:39 AM, Zhao Chenhui <chenhui.zhao@freescale.co=
m> wrote:

> + =A0 =A0 =A0 if (!pmc_regs) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING "PMC is unavailable=
\n");

Use pr_warn() and the other pr_xxx functions.

> + =A0 =A0 =A0 pmcdr_mask =3D (u32 *)of_get_property(clk_np, "fsl,pmcd=
r-mask", NULL);

The typecast is unnecessary here.

> + =A0 =A0 =A0 /* clear to enable clock in low power mode */
> + =A0 =A0 =A0 if (enable)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clrbits32(&pmc_regs->pmcdr, *pmcdr_mask=
);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 setbits32(&pmc_regs->pmcdr, *pmcdr_mask=
);

You need to use be32_to_cpup() when dereferencing a pointer to a
device tree property.

--=20
Timur Tabi
Linux kernel developer at Freescale
