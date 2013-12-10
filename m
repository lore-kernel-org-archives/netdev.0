From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH] net-tg3: Initialize REG_BASE_ADDR at PCI config offset
 120 to 0
Date: Tue, 10 Dec 2013 10:49:39 -0800
Message-ID: <1386701379.1752.26.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <52A633B4.9000307@cogentembedded.com>
	 <1386623253.1752.6.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <1386658724.1752.19.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <20131210.134340.114603867817512238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <sergei.shtylyov@cogentembedded.com>, <natg@google.com>,
	<nsujir@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131210.134340.114603867817512238.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-12-10 at 13:43 -0500, David Miller wrote:

> What if the kernel is booted via kexec, and the driver in the kernel
> we are kexec'ing from left indirect access enabled in MISC_HOST_CTRL?

That should be ok.  The driver will only use valid register offsets in
indirect mode during run time, so register 0x78 should point to a valid
register.  If indirect mode is never used by the driver, it will point
to zero with this patch.  So register 0x78 will be valid (or zero) in
the kexec'ed kernel.
