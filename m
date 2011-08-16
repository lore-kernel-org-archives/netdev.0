From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH 04/14] bna: Add Multiple Tx Queue Support
Date: Wed, 17 Aug 2011 00:43:16 +0100
Message-ID: <1313538196.2725.74.camel@bwh-desktop>
References: <1313529591-3718-1-git-send-email-rmody@brocade.com>
	 <1313529591-3718-5-git-send-email-rmody@brocade.com>
	 <1313531338.2725.63.camel@bwh-desktop>
	 <E5313AF6F2BFD14293E5FD0F94750F86A94D99537C@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Adapter Linux Open SRC Team
	<adapter_linux_open_src_team@Brocade.COM>,
	Gurunatha Karaje <gkaraje@Brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:10501 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551Ab1HPXnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 19:43:20 -0400
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86A94D99537C@HQ1-EXCH01.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-08-16 at 16:32 -0700, Rasesh Mody wrote:
> >From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> >Sent: Tuesday, August 16, 2011 2:49 PM
> >
> >On Tue, 2011-08-16 at 14:19 -0700, Rasesh Mody wrote:
> >> Change details:
> >>  - Add macros bna_prio_allow, bna_default_nw_prio, bna_iscsi_prio,
> >>    bna_is_iscsi_over_cee
> >>  - Added support for multipe Tx queues with a separate iSCSI Tx queue
> >based
> >>    on the default value of iSCSI port number. The feature is supported
> >based
> >>    on the underlying hardware and enabled for DCB (CEE) mode only.
> >>  - Allocate multiple TxQ resource in netdev
> >>  - Implement bnad_tx_select_queue() which enables the correct
> >selection of
> >>    TxQ Id (and tcb). This function is called either by the kernel to
> >channel
> >>    packets to the right TxQ
> >>  - bnad_tx_select_queue() returns priority, while only a few packets
> >during
> >>    transition could have wrong priority, all will be associated with a
> >valid
> >>    non-NULL tcb.
> >>  - Implement bnad_iscsi_tcb_get() and BNAD_IS_ISCSI_PKT() for iSCSI
> >packet
> >>    inspection and retrieval of tcb corresponding to the iSCSI
> >priority.
> >>  - Construction of priority indirection table to be used by bnad to
> >direct
> >>    packets into TxQs
> >[...]
> >
> >You probably should implement TX priority classes through the
> >ndo_setup_tc operation, not ndo_select_queue.
> 
> The reason we went with ndo_select_queue is due to the need for mapping
> iSCSI packets (TCP port 3260) to a priority derived from DCB configuration.
> Here the iSCSI packets may not have any tc defined in the packet header. 

There is an skb priority, which is derived from the socket priority
option (SO_PRIORITY).  If you implement ndo_setup_tc then the networking
core will take care of mapping the skb priority onto a different queue
(or range of queues).

I don't know whether the socket priority option is easily configurable
for the existing iSCSI implementations.  But looking at port numbers
really doesn't seem like the right way to do this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

