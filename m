From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] net/ipv4/arp.c: Fix arp reply when sender ip 0 (was: Strange behavior in arp probe reply, bug or feature?)
Date: Thu, 15 Nov 2007 18:40:32 +0300
Message-ID: <20071115154032.GA30391@ms2.inr.ac.ru>
References: <cac0ab7d0711150340p58eda94ah92894072ba328205@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	jmorris@namei.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Jonas Danielsson <the.sator@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:51400 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755924AbXKOPkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 10:40:47 -0500
Content-Disposition: inline
In-Reply-To: <cac0ab7d0711150340p58eda94ah92894072ba328205@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Send a correct arp reply instead of one with sender ip and sender
> hardware adress in target fields.

I do not see anything more legal in setting target address to 0.


Actually, semantics of target address in ARP reply is ambiguous.
If it is a reply to some real request, it is set to address of requestor
and protocol requires recipient of this arp reply to test that the address
matches its own address before creating new entry triggered by unsolicited
arp reply. That's all.

In the case of duplicate address detection, requestor does not have
any address, so that it is absolutely not essential what we use as target
address. The only place, which could depend on this is the tool, which
tests for duplicate address. At least, arping written by me, should
work with any variant.

So, please, could you explain what did force you to think that use of 0
is better?

Alexey
