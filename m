From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Problems receving multicasts with r8169.c driver from linux
 kernel (2.6.21.5)
Date: Fri, 20 Jul 2007 09:35:34 +0100
Message-ID: <20070720093534.78c1d272@oldman.hamilton.local>
References: <BA41E8A07B73A041948C2E3A4EF6239D062E05@av-digital-exch.avdigital.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Francois Romieu" <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>
To: "Reither Robert" <Robert.Reither@av-digital.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45455 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753592AbXGTIfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 04:35:48 -0400
In-Reply-To: <BA41E8A07B73A041948C2E3A4EF6239D062E05@av-digital-exch.avdigital.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Jul 2007 09:19:15 +0200
"Reither Robert" <Robert.Reither@av-digital.at> wrote:

> 
> Hi Francois ,
> 
> i can spare some time now, so i ask:
> Would it help, if i code/send u a tool to simulate your multicast packet scenario ?
> Buts its possible for me to reproduce the problem with e.g. nc -u 224.1.1.1 10500 <dummy_file (does show me the same bad behaviour).
> Or can i help in another way ?

iperf also works as simple multicast test.
-----------------------------------------------
http://dast.nlanr.net/Projects/Iperf/

Running the multicast server and client
    Use the -B option while starting the server to bind it to a multicast address.
    E.g. :-iperf -s -u -B 224.0.55.55 -i 1.

    This will have the Iperf server listening for datagrams (-u) from the address 224.0.55.55(-B 224.0.55.55), with a periodic reporting interval of 1s (-i 1).

    Now, start a client sending packets to this multicast address, with a TTL depending on your Network Topology (if you are unsure, use a high TTL like 64 or higher).

    E.g. : iperf -c 224.0.55.55 -u -T 32 -t 10 -i 1. This will have a UDP client (-u) connected to the multicast address 224.0.55.55(-c 224.0.55.55), with a TTL of 32 (-T 32), sending data for 10 seconds (-t 10), with a periodic reporting interval of 1s (-i 1).

    Start multiple clients as explained above, sending data to the same multicast server. (If you have multiple servers listening on the multicast address, each of the servers will be getting the data) 
