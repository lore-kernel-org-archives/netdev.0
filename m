From: David Miller <davem@davemloft.net>
Subject: Re: [v2,PCI] move ICHx GbE NVM write-protection from e1000e to PCI
 quirk
Date: Mon, 17 Nov 2008 12:20:49 -0800 (PST)
Message-ID: <20081117.122049.241398620.davem@davemloft.net>
References: <4921C8B0.9060301@redhat.com>
	<20081117.114952.81357471.davem@davemloft.net>
	<B27EBC40D200ED48A3F4CC2EBEABAE0B238BF6E9@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: bruce.w.allan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41873
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752018AbYKQUUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 15:20:49 -0500
In-Reply-To: <B27EBC40D200ED48A3F4CC2EBEABAE0B238BF6E9@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Date: Mon, 17 Nov 2008 12:02:32 -0800

> Well, no, not for every device with an NVRAM; just those LOM parts
> in the ICH-based family of products that has an unprotected region of
> NVRAM and a not-so-difficult set of steps necessary to corrupt the
> NVRAM by taking advantage of that.  By leaving the write-protection in
> the driver, the NVRAM can still be damaged before the driver loads (as
> seen with corruptions from ftrace in 2.6.27) or if the driver is never
> loaded.
>
> Once the NVRAM is write-protected the driver cannot revoke that
> protection, only a system reset will do that.  The kernel command
> line option to disable the write protection is so that if/when a
> user needs to change a value in the NVRAM it can still be done.

It seems to me the ftrace case could have triggered before PCI
even initializes.

Why not, therefore, write a very-early-initcall mini-driver that
does this instead?
