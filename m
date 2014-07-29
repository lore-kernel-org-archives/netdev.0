From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/4] remove deprecated syststamp
Date: Tue, 29 Jul 2014 11:40:44 -0700 (PDT)
Message-ID: <20140729.114044.377340575518627384.davem@davemloft.net>
References: <1406325692-616-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	kreese@caviumnetworks.com, ddaney@caviumnetworks.com,
	dborkman@redhat.com, jdmason@kudzu.us
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbaG2Sks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 14:40:48 -0400
In-Reply-To: <1406325692-616-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Fri, 25 Jul 2014 18:01:28 -0400

> The network stack can generate two kinds of hardware timestamps:
> - hwtstamp stores a hw timestamp in device-specific raw format
> - syststamp convers the raw format to system time
> 
> The second is deprecated and only implemented by a single device
> driver. The suggested alternative is to communicate hwtstamp +
> directly expose the NIC PTP clock device through ptp_clock_info.
> The remaining driver (octeon) does not expose such a standard
> interface as of now. It does have its own PTP library that depends
> on its own shared memory PTP clock interface.
> 
> This patchset
> 1. reverts the syststamp code in the one driver (octeon)
> 2. reverts an unnecessary zero initialization in another (vxge)
> 3. modifies PF_PACKET to use syststamp is != 0 (because always == 0)
> 4. modifies SCM_TIMESTAMPING in the same way
> 
> For backwards compatibility, the interfaces are not removed.
> Applications can still request SOF_TIMESTAMPING_SYS_HARDWARE. The
> response field in scm_timestamping also remains. As was the case
> for hardware/drivers that did not implement the feature, the
> setsockopt succeeds, but the response field is always zero.

Series applied, thanks Willem.
