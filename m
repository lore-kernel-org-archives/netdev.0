From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 18:02:43 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F143AEE0@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: jeff@garzik.org, kelly@au1.ibm.com, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1551 "EHLO mms2.broadcom.com")
	by vger.kernel.org with ESMTP id S1751061AbWD0BCz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 21:02:55 -0400
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> From: "Caitlin Bestler" <caitlinb@broadcom.com>
> Date: Wed, 26 Apr 2006 15:53:44 -0700
> 
>> The netchannel qualifiers should only deal with TCP packets for
>> established connections. Listens would continue to be dealt with by
>> the existing stack logic, vj_channelizing only occurring when the the
>> connection was accepted.
> 
> I consider netchannel support for listening TCP sockets to be
> absolutely essential. -

Meaning that inbound SYNs would be placed in a net channel
for processing by a Consumer at the other end of the ring?

If so the rules filtering SYNs would have to be applied either
before it went into the ring, or when the consumer end takes
them out. The latter makes more sense to me, because the rules
about what remote hosts can initiate a connection request to
a given TCP port can be fairly complex for a variety of
legitimate reasons.

Would it be reasonable to state that a net channel carrying
SYNs should not be set up when the consumer is a user mode
process?



