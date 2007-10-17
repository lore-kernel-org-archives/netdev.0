From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: multicast: bug or "feature"
Date: Wed, 17 Oct 2007 16:23:07 -0400
Message-ID: <47166F2B.5010706@hp.com>
References: <OF5E5E93CF.68389D89-ON88257377.006E39CF-88257377.006EB529@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, netdev <netdev@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:44116 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757164AbXJQUX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 16:23:29 -0400
In-Reply-To: <OF5E5E93CF.68389D89-ON88257377.006E39CF-88257377.006EB529@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> I'm not clear on your configuration.
> 
> Are the sender and receiver running on the same machine? Are
> you saying eth0 and eth1 are connected on the same link?

Yes and Yes.

I know it's a strange config, but it works with IPv6.

Here is the info off the reproducing system:

# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:17:08:7D:47:18  
          inet addr:10.202.1.23  Bcast:10.202.255.255  Mask:255.255.0.0
          inet6 addr: 2001:1890:1109:a10:217:8ff:fe7d:4718/64 Scope:Global
          inet6 addr: fe80::217:8ff:fe7d:4718/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1094 errors:0 dropped:0 overruns:0 frame:0
          TX packets:669 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:107776 (105.2 KiB)  TX bytes:109874 (107.2 KiB)
          Base address:0x4000 Memory:f9de0000-f9e00000 

eth1      Link encap:Ethernet  HWaddr 00:18:FE:7F:49:C8  
          inet addr:10.202.1.26  Bcast:10.202.255.255  Mask:255.255.0.0
          inet6 addr: 2001:1890:1109:a10:218:feff:fe7f:49c8/64 Scope:Global
          inet6 addr: fe80::218:feff:fe7f:49c8/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:479 errors:0 dropped:0 overruns:0 frame:0
          TX packets:35 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:52236 (51.0 KiB)  TX bytes:4467 (4.3 KiB)
          Interrupt:41 Memory:f6000000-f6012100 


# ip r l
10.202.0.0/16 dev eth0  proto kernel  scope link  src 10.202.1.23 
10.202.0.0/16 dev eth1  proto kernel  scope link  src 10.202.1.26 
default via 10.202.1.1 dev eth0


-vlad
