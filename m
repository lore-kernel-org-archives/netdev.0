From: "Merav Sicron" <meravs@broadcom.com>
Subject: Re: [net-next patch v2] bnx2x: Add run-time CNIC support
Date: Tue, 10 Jul 2012 15:17:00 +0300
Message-ID: <1341922620.27284.16.camel@lb-tlvb-meravs.il.broadcom.com>
References: <1341828055-4467-1-git-send-email-meravs@broadcom.com>
 <20120709.141010.996787793429264956.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, dmitry@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4201 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754775Ab2GJMSO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 08:18:14 -0400
In-Reply-To: <20120709.141010.996787793429264956.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-09 at 14:10 -0700, David Miller wrote:
> From: "Merav Sicron" <meravs@broadcom.com>
> Date: Mon, 9 Jul 2012 13:00:55 +0300
> 
> > -	max_non_def_sbs = bnx2x_get_num_non_def_sbs(pdev);
> > +	cnic_enabled = IS_ENABLED(CONFIG_CNIC) ? 1 : 0;
> 
> This, as I said, it pointless.
> 
> Every distribution is going to turn on this Kconfig option so guarding
> this at all using the Kconfig option is largely valueless.
> 

There are still two advantages in disabling CNIC in bnx2x: Saving
resources (MSI-X vector and memory) as well as reducing some latency.
When the HW is configured to storage-offload  (rather than NIC-only
mode) it does connection search over the PCI, which is additional
0.5usec - 2.5usec, depending on the system load. When CNIC is not
enabled, the HW is configured to eliminate the search.

While it is true that distributions enable the CNIC Kconfig option, some
users that care about resources and latency compile a kernel without it.

Can you please re-consider this patch?

Thanks,
Merav
