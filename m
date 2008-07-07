From: David Miller <davem@davemloft.net>
Subject: Re: setsockopt()
Date: Mon, 07 Jul 2008 14:49:12 -0700 (PDT)
Message-ID: <20080707.144912.76654646.davem@davemloft.net>
References: <48725DFE.6000504@citi.umich.edu>
	<20080707142408.43aa2a2e@extreme>
	<48728B09.1050801@citi.umich.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu,
	bfields@fieldses.org
To: aglo@citi.umich.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54568
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756113AbYGGVtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 17:49:13 -0400
In-Reply-To: <48728B09.1050801@citi.umich.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>
Date: Mon, 07 Jul 2008 17:30:49 -0400

> Auto-tuning would be guided by the sysctl values that are set for all 
> applications. I could be wrong but what I see is that unless an 
> application does a setsockopt(), its window is bound by the default 
> sysctl value. If it is true, than it is not acceptable. It means that in 
> order for NFSD to achieve a large enough window it needs to modify TCP's 
> sysctl value which will effect all other applications.

This is nonsense.

The kernel autotunes the receive and send buffers based upon the
dynamic behavior of the connection.

The sysctls only control limits.

If you set the socket buffer sizes explicitly, you essentially turn
off half of the TCP stack because it won't do dynamic socket buffer
sizing afterwards.

There is no reason these days to ever explicitly set the socket
buffer sizes on TCP sockets under Linux.

If something is going wrong it's a bug and we should fix it.
