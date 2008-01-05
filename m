From: James Chapman <jchapman@katalix.com>
Subject: Re: NAPI poll behavior in various Intel drivers
Date: Sat, 05 Jan 2008 00:18:31 +0000
Message-ID: <477ECCD7.8090905@katalix.com>
References: <20080104.034036.160194618.davem@davemloft.net>	<477E92B6.8010809@katalix.com> <20080104.132443.25068269.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:54320 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753911AbYAEASf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2008 19:18:35 -0500
In-Reply-To: <20080104.132443.25068269.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Fri, 04 Jan 2008 20:10:30 +0000
> 
>> With the latest NAPI, this code has to change. But rather than remove
>> the tx_cleaned logic completely, shouldn't transmit processing be
>> included in the work_done accounting when a driver does transmit cleanup
>> processing in the poll?
> 
> Most other NAPI drivers don't do this, they just process all the
> pending TX work unconditionally and do not account it into the NAPI
> poll work.

This will cause the interface to thrash in/out of polled mode very
quickly when it is doing almost all transmit work. That's something to
avoid, no?

> The logic is that, like link state handling, TX work is very cheap and
> not the cpu cycle eater that RX packet processing is.

The processing is cheap but it is being done in the poll so it is
scheduled by NAPI. The event rate for TX events can be just as high as
RX. For link state handling, the event rate is always low so won't cause
NAPI to schedule rapidly.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

