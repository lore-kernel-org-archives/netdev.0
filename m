From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Fri, 30 May 2008 00:00:09 -0700 (PDT)
Message-ID: <20080530.000009.02995266.davem@davemloft.net>
References: <483CB301.40007@sun.com>
	<20080528.223415.193732490.davem@davemloft.net>
	<483F46E5.9030707@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper@krogh.cc, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49069
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751386AbYE3HAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 03:00:13 -0400
In-Reply-To: <483F46E5.9030707@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Thu, 29 May 2008 17:14:29 -0700

> Actually what I am suggesting was a workaround for the lack of "TX Ring 
> Empty" interrupt by not relying on the TX interrupt at all.

Ahh I see.

Some of the things I talked about in my presentation here in
Berlin at LinuxTAG yesterday can help mitigate the effects.
Most of it revolves around batching, and allowing the driver
to manage the backlog of packets directly when the TX queue
fills up.

In such a case we could batch the TX queue refill, know how many more
TX packets we will queue up to the chip right now, and therefore know
that we can safely set periodic MARK bits and only need to force set
the MARK bit at the very end.

> As for the TX hang, I will try to reproduce the problem and look at
> the registers for the clue.

Thanks a lot.
