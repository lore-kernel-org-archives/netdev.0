From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC] new qla3xxx NIC Driver v2.02.00k19
Date: Wed, 17 May 2006 01:23:46 +0200
Message-ID: <20060516232346.GA20608@electric-eye.fr.zoreil.com>
References: <0BB3E5E7462EEA4295BC02D49691DC070D32F3@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	Ying Ping Lok <ying.lok@qlogic.com>,
	Mike Metskas <mike.metskas@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:29859 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932274AbWEPX1u
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 19:27:50 -0400
To: Ron Mercer <ron.mercer@qlogic.com>
Content-Disposition: inline
In-Reply-To: <0BB3E5E7462EEA4295BC02D49691DC070D32F3@AVEXCH1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ron Mercer <ron.mercer@qlogic.com> :
[...]
> Looking forward to any and all feedback.

First pass:
- please reorder the code so that the forward declarations are not needed
- the typedefs (say PQL3XXX_PORT_REGISTERS) hide pointer information.
  They are useless (and capitalized :o/ ). Just say no to typedef.
- the debug functions abuse copy/paste. Please use struct array + loop
  if you really want these to stay.
- "return" is not a function. It does not need parenthesis.
- 80 colums disease in ql_link_state_machine. The indentation is terrible.
- label for goto should be at the start of the line.
- acquire_adapter_lock must go. Conditional locking is a pain to maintain.
- the error path in ql3xxx_probe is broken. Use named _and_ numbered
  goto if you want to avoid it (i.e. "goto err_undo_something_1" then
  "goto err_undo_something_else_2", etc.).
- ql_set_ethtool_ops() is useless bloat. Please remove.
- QL_LOCK_DRVR_WAIT should be a function, not a macro
- the status code should be propagated (request_irq, pci_enable_device,
  pci_request_regions, etc.).
- no __iomem, __u32, __le32 ? Seems strange.
- replace return (0) with NETDEV_TX_OK in ql3xxx_send
  (and s/send/start_xmit/ ?).

-- 
Ueimor
