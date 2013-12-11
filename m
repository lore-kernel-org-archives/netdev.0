From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-tg3: Initialize REG_BASE_ADDR at PCI config offset
 120 to 0
Date: Tue, 10 Dec 2013 22:23:13 -0500 (EST)
Message-ID: <20131210.222313.694303616856894486.davem@davemloft.net>
References: <1386658724.1752.19.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<20131210.134340.114603867817512238.davem@davemloft.net>
	<1386701379.1752.26.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, natg@google.com,
	nsujir@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mchan@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386701379.1752.26.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Chan <mchan@broadcom.com>
Date: Tue, 10 Dec 2013 10:49:39 -0800

> On Tue, 2013-12-10 at 13:43 -0500, David Miller wrote:
> 
>> What if the kernel is booted via kexec, and the driver in the kernel
>> we are kexec'ing from left indirect access enabled in MISC_HOST_CTRL?
> 
> That should be ok.  The driver will only use valid register offsets in
> indirect mode during run time, so register 0x78 should point to a valid
> register.  If indirect mode is never used by the driver, it will point
> to zero with this patch.  So register 0x78 will be valid (or zero) in
> the kexec'ed kernel.

Ok, that may be true, but I'd like to consider the much larger issue
at hand.

If the indirect mechanism is enabled, some of the offsets that may be
in there might be value, but would be entirely undesirable to be read
because the read has side effects.

What if the interrupt status register is what gets read if the user
scans config space at just the wrong moment, and therefore an
interrupt gets lost?

I understand that the patch we are discussing is a serious improvement
from the current situation, so I will apply it and queue it up for
-stable.

However I think we need to do something reasonable to prevent the
kinds of situations I described above.

Thanks.
