From: David Miller <davem@davemloft.net>
Subject: Re: [TCP] IPV6 : Change a divide into a right shift in
 tcp_v6_send_ack()
Date: Fri, 21 Dec 2007 01:46:20 -0800 (PST)
Message-ID: <20071221.014620.91361895.davem@davemloft.net>
References: <476B65F8.10201@cosmosbay.com>
	<20071221.162833.82587283.yoshfuji@linux-ipv6.org>
	<476B6DAC.2030102@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59587
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753264AbXLUJqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 04:46:21 -0500
In-Reply-To: <476B6DAC.2030102@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 21 Dec 2007 08:39:24 +0100

> I didnt chose this path, because David was against changing some
> fields from 'int' to 'unsigned'. If you look in other parts of
> networking, we have many >> 1 or >> 2 already there.

I don't remember making this statement, where did I say this?
I'm genuinely curious :-)

But I am indeed against it in cases where the variable is compared
against signed quantities.

I think the shifts are more pretty and more closely match what the
programmer wants to come out of the compiler.  Getting all of these
divides is an awful surprise for me.

I've learned over the years to never explicitly code divides
or multiplies by powers of two and to always use shifts.  As
a result I am never surprised.  In fact I've been burnt every
time I mistakedly didn't use a shift.

Nevertheless, this tcplen arg is always assigned to and used
with unsigned quantities so I'll apply Yoshifuji's version of
the fix.
