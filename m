From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Fri, 30 Mar 2007 13:46:26 -0700
Message-ID: <460D7722.8030403@hp.com>
References: <20070327214754.GA11677@dag-work>	<20070327.153025.45876618.davem@davemloft.net>	<46d726f90703290756k1894b0aal8df85d46d8c2a25e@mail.gmail.com>	<20070329.114139.55510589.davem@davemloft.net>	<460C6348.5030904@osdl.org>	<46d726f90703300810q619e8bbmb5b15a58ff37bbed@mail.gmail.com>	<460D57FC.6080007@linux-foundation.org> <46d726f90703301209o1147385fx9151c10f95e16684@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, dagriego@gmail.com,
	netdev@vger.kernel.org
To: Predrag Hodoba <predrag.hodoba@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:33992 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753624AbXC3Uqa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 16:46:30 -0400
In-Reply-To: <46d726f90703301209o1147385fx9151c10f95e16684@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the switchover from active to standby is "commanded" then there is 
the opportunity to "tell" the applications on the server to close their 
connections - either explicitly with some sort of defined interface, or 
implicitly by killing the processes.  Then the IP can be brought-up on 
the standby and processes started/enabled/whatever and the clients can 
establish their new connections.  The ioctl here (at least if it is like 
the tcp_discon options in HP-UX/Solaris) wouldn't be any better than 
just killing the process in so far as what happens on the network - in 
fact, it could be worse since the RST will not be retransmitted if lost, 
but FINs would.  So, the ioctl could still leave clients twisting in the 
ether waiting for their application-level heartbeats to kick-in anyway. 
  Heck, depending on their heartbeat lengths, even the FIN stuff if lost 
could leave them depending on their heartbeats.

If the switchover from active to standby is "uncommanded" it probably 
means the primary went belly-up which means you don't have the 
opportunity to make an ioctl call anyway, and you are back to the 
heartbeats.

rick jones
