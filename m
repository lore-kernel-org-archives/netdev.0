From: Andi Kleen <andi@firstfloor.org>
Subject: Re: TCP/IP stack interpretation of acceptable packet
Date: Sat, 28 Feb 2009 16:50:46 +0100
Message-ID: <87iqmu36i1.fsf@basil.nowhere.org>
References: <2ff60cd60902241459q1de39054lb3dc5233f13b69c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Oliver Zheng <mailinglists+netdev@oliverzheng.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49202 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbZB1Pwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 10:52:43 -0500
In-Reply-To: <2ff60cd60902241459q1de39054lb3dc5233f13b69c3@mail.gmail.com> (Oliver Zheng's message of "Tue, 24 Feb 2009 14:59:55 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Zheng <mailinglists+netdev@oliverzheng.com> writes:

> I was investigating behaviour of the TCP/IP stacks and noticed that
> Linux has a peculiarity. When a packet is received with the correct
> sequence number but incorrect acknowledgement number (in my tests, it
> was higher than the correct acknowledgement number), the stack accepts
> the packet as a valid packet and passes the data up to the application
> (I do not know whether the ack information is accepted). According to
> the list of tests described here in the TCP RFC 793 [1], accepting a
> packet requires the packet to satisfy both sequence and
> acknowledgement number tests; otherwise, the entirety of the packet
> (its data and its acknowledgement information confirming reception of
> previous data) should be dropped. Is this intentional, a bug, or am I
> misinterpreting something? A nice flow chart that explains this
> procedure is here [2].

Sounds like a bug to me, when the ack is outside the window.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
