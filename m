From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [TG3 1/8]: Save MSI state before suspend.
Date: Tue, 13 Feb 2007 11:58:25 -0800
Message-ID: <20070213115825.0a6119ed@freekitty>
References: <1171397612.18944.25.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:49926 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893AbXBMT63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:58:29 -0500
In-Reply-To: <1171397612.18944.25.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Feb 2007 12:13:32 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> [TG3]: Save MSI state before suspend.
> 
> This fixes the following problem:
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=7969
> 
> The MSI state needs to be saved during suspend.  PCI state saved
> during tg3_init_one() does not contain valid MSI state because
> MSI hasn't been enabled.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> 

I think you have to move the original pci_save_state call, otherwise
you will call pci_save_state twice and leak memory.  pci_save_state
allocates memory to store MSI and other information. Look at pci_save_pcie_state
etc.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
