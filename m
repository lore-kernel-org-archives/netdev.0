From: David Miller <davem@davemloft.net>
Subject: Re: Bug 7596 - Potential performance bottleneck for Linxu TCP
Date: Wed, 29 Nov 2006 17:01:41 -0800 (PST)
Message-ID: <20061129.170141.23017532.davem@davemloft.net>
References: <HNEBLGGMEGLPMPPDOPMGKEAJCGAA.wenji@fnal.gov>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37773
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S967770AbWK3BBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 20:01:38 -0500
To: wenji@fnal.gov
In-Reply-To: <HNEBLGGMEGLPMPPDOPMGKEAJCGAA.wenji@fnal.gov>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The delays dealt with in your paper might actually help a highly
loaded server with lots of sockets and threads trying to communicate.

The packet processing delays caused by the scheduling delay paces the
TCP sender by controlling the rate at which ACKs go back to that
sender.  Those ACKs will go out paced to the rate at which the
sleeping TCP receiver gets back onto the cpu, and this will cause the
TCP sender to naturally adjust to the overall processing rate of the
receiver system, on a per-connection basis.

Perhaps try a system with hundreds of processes and potentially
hundreds of thousands of TCP sockets, with thousands of unique sender
sites, and see what happens.

This is a similar topic like TSO, where we are trying to balance the
gains from batching work from the losses of gaps in the communication
stream.
