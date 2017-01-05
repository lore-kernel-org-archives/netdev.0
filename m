From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] tools: psock_tpacket: block Rx until
 socket filter has been added and socket has been bound to loopback.
Date: Thu, 05 Jan 2017 15:04:30 -0500 (EST)
Message-ID: <20170105.150430.839990438445567255.davem@davemloft.net>
References: <cover.1483642577.git.sowmini.varadhan@oracle.com>
        <6b77972e99e49096676e04854067a44226e926aa.1483642577.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, willemb@google.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48704 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934554AbdAEUEc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 15:04:32 -0500
In-Reply-To: <6b77972e99e49096676e04854067a44226e926aa.1483642577.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu,  5 Jan 2017 11:06:22 -0800

> Packets from any/all interfaces may be queued up on the PF_PACKET socket
> before it is bound to the loopback interface by psock_tpacket, and
> when these are passed up by the kernel, they could interfere
> with the Rx tests.
> 
> Avoid interference from spurious packet by blocking Rx until the
> socket filter has been set up, and the packet has been bound to the
> desired (lo) interface. The effective sequence is
> 	socket(PF_PACKET, SOCK_RAW, 0);
> 	set up ring
> 	Invoke SO_ATTACH_FILTER
> 	bind to sll_protocol set to ETH_P_ALL, sll_ifindex for lo
> After this sequence, the only packets that will be passed up are
> those received on loopback that pass the attached filter.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Applied, thanks.
