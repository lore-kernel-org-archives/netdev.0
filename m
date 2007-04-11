From: David Miller <davem@davemloft.net>
Subject: Re: TCP connection stops after high load.
Date: Wed, 11 Apr 2007 13:41:42 -0700 (PDT)
Message-ID: <20070411.134142.108807479.davem@davemloft.net>
References: <461D2DEA.4010806@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45828
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030812AbXDKUln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 16:41:43 -0400
In-Reply-To: <461D2DEA.4010806@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Wed, 11 Apr 2007 11:50:18 -0700

> So, I would like to dig into this problem myself since no one else
> is reporting this type of problem, but I am quite ignorant of the TCP
> stack implementation.  Based on the dup-acks I see on the wire, I assume
> the TCP state machine is messed up somehow.  Could anyone point me to
> likely places in the TCP stack to start looking for this bug?

Dup acks mean that packets are being dropped and there are thus holes
in the sequence seen at the receiver.

Likely what happens is that we hit the global memory pressure
limit, start dropping packets, and never recover even after the
memory pressure is within it's limits again.
