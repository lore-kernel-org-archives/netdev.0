From: David Miller <davem@davemloft.net>
Subject: Re: Stale entries in RT_TABLE_LOCAL
Date: Wed, 09 Mar 2011 13:53:08 -0800 (PST)
Message-ID: <20110309.135308.102544831.davem@davemloft.net>
References: <201102231243.23579.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg
To: alexandre.sidorenko@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46765
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751767Ab1CIVwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 16:52:30 -0500
In-Reply-To: <201102231243.23579.alexandre.sidorenko@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Date: Wed, 23 Feb 2011 12:43:23 -0500

> I am not sure what is the best way to fix this, I can think of several 
> approaches:
> 
>   (a) change the sources so that it would be impossible to add the same IP 
>       multiple times, even with different masks. I cannot think of any
>       situation where adding the same IP (but with different mask) to the same
>       interface could be useful. But maybe I am wrong?

I'm leaning towards this solution if it's viable.  But I'm not so sure that
nobody uses this feature, maybe Julian knows?

Julian, the issue is that if you add the same IP address multiple times using
different subnet masks, we allow it.

But removal doesn't work correctly, we clear the IFA list on the device but we
leave stale entries in the local routing table.

The test case is:

ip addr add 192.168.142.109/23 dev dummy0
ip addr add 192.168.142.109/22 dev dummy0
ip addr del 192.168.142.109/22 dev dummy0
ip addr del 192.168.142.109/23 dev dummy0
