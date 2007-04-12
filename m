From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: TCP connection stops after high load.
Date: Thu, 12 Apr 2007 20:19:40 +0200
Message-ID: <20070412201940.7f570b6d.dada1@cosmosbay.com>
References: <461D2DEA.4010806@candelatech.com>
	<461D447C.4070408@candelatech.com>
	<20070411.134804.50594117.davem@davemloft.net>
	<461D4DD7.7020207@candelatech.com>
	<p73y7kx7iol.fsf@bingen.suse.de>
	<461E7377.3020708@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	bcrl@kvack.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:38049 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030664AbXDLSTl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 14:19:41 -0400
In-Reply-To: <461E7377.3020708@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Apr 2007 10:59:19 -0700
Ben Greear <greearb@candelatech.com> wrote:
> 
> Here is a tcpdump of the connection in the stalled state.  As you can see by
> the 'time' output, it's running at around 100,000 packets per second.  tcpdump
> dropped the vast majority of these.  Based on the network interface stats, I
> believe both sides of the connection are sending acks at about the same
> rate (about 160kpps when tcpdump is not running it seems).

Warning : tcpdump can lie, telling you packets being transmited several time.

And yes, tcpdump slow things down because of enabling accurate timestamping of packets.

> 
> 
> 10:46:46.541490 IP 20.20.20.20.33011 > 20.20.20.30.33012: . ack 48 win 6132 <nop,nop,timestamp 85158912 84963208>
> 10:46:46.541494 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158912 84963208>
> 10:46:46.541567 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158912 84963208>
> 10:46:46.541653 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158912 84963208>
> 10:46:46.541886 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158912 84963208>
> 10:46:46.541891 IP 20.20.20.20.33011 > 20.20.20.30.33012: . ack 48 win 6132 <nop,nop,timestamp 85158912 84963208>
> 10:46:46.541895 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158912 84963208>
> 10:46:46.541988 IP 20.20.20.30.33012 > 20.20.20.20.33011: . ack 1 win 114 <nop,nop,timestamp 85158912 84963208>
>

What 
"tc -s -d qdisc"
"ifconfig -a"
"cat /proc/interrupts" 
"cat /proc/net/sockstat" and
"cat /proc/net/softnet_stat" are telling ?

