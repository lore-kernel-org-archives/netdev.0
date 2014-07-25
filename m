From: Willem de Bruijn <willemb@google.com>
Subject: [net-next 0/4] remove deprecated syststamp
Date: Fri, 25 Jul 2014 18:01:28 -0400
Message-ID: <1406325692-616-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, richardcochran@gmail.com,
	kreese@caviumnetworks.com, ddaney@caviumnetworks.com,
	dborkman@redhat.com, jdmason@kudzu.us,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:43735 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbaGYWBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 18:01:43 -0400
Received: by mail-oa0-f74.google.com with SMTP id eb12so1402560oac.3
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 15:01:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network stack can generate two kinds of hardware timestamps:
- hwtstamp stores a hw timestamp in device-specific raw format
- syststamp convers the raw format to system time

The second is deprecated and only implemented by a single device
driver. The suggested alternative is to communicate hwtstamp +
directly expose the NIC PTP clock device through ptp_clock_info.
The remaining driver (octeon) does not expose such a standard
interface as of now. It does have its own PTP library that depends
on its own shared memory PTP clock interface.

This patchset
1. reverts the syststamp code in the one driver (octeon)
2. reverts an unnecessary zero initialization in another (vxge)
3. modifies PF_PACKET to use syststamp is != 0 (because always == 0)
4. modifies SCM_TIMESTAMPING in the same way

For backwards compatibility, the interfaces are not removed.
Applications can still request SOF_TIMESTAMPING_SYS_HARDWARE. The
response field in scm_timestamping also remains. As was the case
for hardware/drivers that did not implement the feature, the
setsockopt succeeds, but the response field is always zero.

-- 
2.0.0.526.g5318336
