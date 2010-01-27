From: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Subject: Re: CBQ broken in 2.6
Date: Wed, 27 Jan 2010 12:28:28 +0000
Message-ID: <1264595308.29501.30.camel@tranquility.sigsegv.cx>
References: <1264590347.29501.11.camel@tranquility.sigsegv.cx>
	 <20100127.035635.173712880.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab2.miniserver.com ([89.200.136.192]:42991 "EHLO
	www.sigsegv.cx" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751202Ab0A0Myo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2010 07:54:44 -0500
In-Reply-To: <20100127.035635.173712880.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks it is indeed sch_cbq.c,

I have been going through the code in the meantime and found a place
where cl->tparent can be modified further down in the routine in
question. There is an invocation of cbq_set_lss() around the end of
cbq_change_class() which can do that.

I am rebuilding the kernel for my CBQ box with a few printks at the
moment to see if it modified there or not.

In any case here is the tell-tale symptom:

class cbq 1:16 parent 1: leaf 76: rate 5600Kbit (bounded,isolated) prio
2
 Sent 162051 bytes 925 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
  borrowed 201 overactions 0 avgidle 78 undertime 0

That is a bounded class. Its borrowed should be always 0 no matter what.
That is basically a broken CBQ implementation.

An elementary network test suite shows the same result - it is being
allowed to borrow.

I am happy to send the whole config if necessary if someone wants to
look at it.

Brgds,

[snip]

-- 
   Understanding is a three-edged sword:
            your side, their side, and the truth. --Kosh Naranek

A. R. Ivanov
E-mail:  anton.ivanov@kot-begemot.co.uk
WWW:     http://www.kot-begemot.co.uk/


