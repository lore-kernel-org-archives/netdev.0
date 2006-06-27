From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH Round 2 0/2][RFC] Network Event Notifier Mechanism
Date: Tue, 27 Jun 2006 13:27:35 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F15F5A49@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:61708 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1161283AbWF0U15 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:27:57 -0400
Content-class: urn:content-classes:message
To: "David Miller" <davem@davemloft.net>, swise@opengridcomputing.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> From: Steve Wise <swise@opengridcomputing.com>
> Date: Tue, 27 Jun 2006 10:02:19 -0500
> 
>> For the RDMA kernel subsystem, however, we still need a specific
>> event. We need both the old and new dst_entry struct ptrs to figure
>> out which active connections were using the old dst_entry and should
>> be updated to use the new dst_entry.
> 
> This change isn't truly atomic from a kernel standpoint either.
> 
> The new dst won't be selected by the socket until later, when
> the socket tries to send something, notices the old dst is
> obsolete, and looks up a new one.
> 
> Your code could do the same thing.

The request to "send something" is posted directly form user
mode to a mapped memory ring that is reaped by the hardware.
Having the hardware fault, report that fault, and wait for
the host to update it with the new mapping is somewhat clumbsy.
It also won't work at all for existing hardware.

The best you could do is to have the driver invalidate the old
entry, then *presume* that the hardware will want the replacement
and look that up, and then forward that answer to the hardware.

