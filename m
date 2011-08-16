From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 04/14] bna: Add Multiple Tx Queue Support
Date: Tue, 16 Aug 2011 22:48:58 +0100
Message-ID: <1313531338.2725.63.camel@bwh-desktop>
References: <1313529591-3718-1-git-send-email-rmody@brocade.com>
	 <1313529591-3718-5-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	adapter_linux_open_src_team@brocade.com,
	Gurunatha Karaje <gkaraje@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:3239 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074Ab1HPVtC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 17:49:02 -0400
In-Reply-To: <1313529591-3718-5-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-08-16 at 14:19 -0700, Rasesh Mody wrote:
> Change details:
>  - Add macros bna_prio_allow, bna_default_nw_prio, bna_iscsi_prio,
>    bna_is_iscsi_over_cee
>  - Added support for multipe Tx queues with a separate iSCSI Tx queue based
>    on the default value of iSCSI port number. The feature is supported based
>    on the underlying hardware and enabled for DCB (CEE) mode only.
>  - Allocate multiple TxQ resource in netdev
>  - Implement bnad_tx_select_queue() which enables the correct selection of
>    TxQ Id (and tcb). This function is called either by the kernel to channel
>    packets to the right TxQ
>  - bnad_tx_select_queue() returns priority, while only a few packets during
>    transition could have wrong priority, all will be associated with a valid
>    non-NULL tcb.
>  - Implement bnad_iscsi_tcb_get() and BNAD_IS_ISCSI_PKT() for iSCSI packet
>    inspection and retrieval of tcb corresponding to the iSCSI priority.
>  - Construction of priority indirection table to be used by bnad to direct
>    packets into TxQs
[...]

You probably should implement TX priority classes through the
ndo_setup_tc operation, not ndo_select_queue.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

