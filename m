From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 12:38:53 -0800 (PST)
Message-ID: <20061130.123853.10298783.davem@davemloft.net>
References: <20061130103240.GA25733@elte.hu>
	<20061130.122258.68041055.davem@davemloft.net>
	<20061130203026.GD14696@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, nickpiggin@yahoo.com.au, wenji@fnal.gov,
	akpm@osdl.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60884
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031407AbWK3Uiv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 15:38:51 -0500
To: mingo@elte.hu
In-Reply-To: <20061130203026.GD14696@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 30 Nov 2006 21:30:26 +0100

> disk I/O is typically not CPU bound, and i believe these TCP tests /are/ 
> CPU-bound. Otherwise there would be no expiry of the timeslice to begin 
> with and the TCP receiver task would always be boosted to 'interactive' 
> status by the scheduler and would happily chug along at 500 mbits ...

It's about the prioritization of the work.

If all disk I/O were shut off and frozen while we copy file
data into userspace, you'd see the same problem for disk I/O.
