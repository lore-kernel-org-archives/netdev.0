From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix psock_fanout selftest hash collision
Date: Wed, 20 Mar 2013 13:59:34 -0400 (EDT)
Message-ID: <20130320.135934.156565403641352244.davem@davemloft.net>
References: <CA+FuTSeN1wXrSP8-piCdnv8MuqgokndSYsiidvdtC=d2tCqcDQ@mail.gmail.com>
	<1363761764-4374-1-git-send-email-willemb@google.com>
	<20130320.123344.1566685302188091721.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046Ab3CTR7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:59:37 -0400
In-Reply-To: <20130320.123344.1566685302188091721.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 20 Mar 2013 12:33:44 -0400 (EDT)

> From: Willem de Bruijn <willemb@google.com>
> Date: Wed, 20 Mar 2013 02:42:44 -0400
> 
>> Fix flaky results with PACKET_FANOUT_HASH depending on whether the
>> two flows hash into the same packet socket or not.
>> 
>> Also adds tests for PACKET_FANOUT_LB and PACKET_FANOUT_CPU and
>> replaces the counting method with a packet ring.
>> 
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
> 
> Applied, thanks.  I'll retest on my sparc64 box later today.

Unfortunately, it's still broken there:

--------------------
running psock_fanout test
--------------------
test: control single socket
test: control multiple sockets
test: datapath 0x0
info: count=0,0, expect=0,0
info: count=0,0, expect=15,5
ERROR: incorrect queue lengths
info: count=0,0, expect=20,5
ERROR: incorrect queue lengths
info: trying alternate ports (4)
test: datapath 0x0
info: count=0,0, expect=0,0
info: count=0,0, expect=15,5
ERROR: incorrect queue lengths
info: count=0,0, expect=20,5
ERROR: incorrect queue lengths
info: trying alternate ports (3)
test: datapath 0x0
info: count=0,0, expect=0,0
info: count=0,0, expect=15,5
ERROR: incorrect queue lengths
info: count=0,0, expect=20,5
ERROR: incorrect queue lengths
info: trying alternate ports (2)
test: datapath 0x0
info: count=0,0, expect=0,0
info: count=0,0, expect=15,5
ERROR: incorrect queue lengths
info: count=0,0, expect=20,5
ERROR: incorrect queue lengths
info: trying alternate ports (1)
test: datapath 0x0
info: count=0,0, expect=0,0
info: count=0,0, expect=15,5
ERROR: incorrect queue lengths
info: count=0,0, expect=20,5
ERROR: incorrect queue lengths
info: trying alternate ports (0)
test: datapath 0x0
info: count=0,0, expect=0,0
info: count=0,0, expect=15,5
ERROR: incorrect queue lengths
info: count=0,0, expect=20,5
ERROR: incorrect queue lengths
test: datapath 0x1000
info: count=0,0, expect=0,0
info: count=0,0, expect=15,5
ERROR: incorrect queue lengths
info: count=0,0, expect=20,15
ERROR: incorrect queue lengths
test: datapath 0x1
info: count=0,0, expect=0,0
info: count=0,0, expect=10,10
ERROR: incorrect queue lengths
info: count=0,0, expect=18,17
ERROR: incorrect queue lengths
test: datapath 0x3
info: count=0,0, expect=0,0
info: count=0,0, expect=20,0
ERROR: incorrect queue lengths
info: count=0,0, expect=20,15
ERROR: incorrect queue lengths
test: datapath 0x2
info: count=0,0, expect=0,0
info: count=0,0, expect=20,0
ERROR: incorrect queue lengths
info: count=0,0, expect=20,0
ERROR: incorrect queue lengths
test: datapath 0x2
info: count=0,0, expect=0,0
info: count=0,0, expect=0,20
ERROR: incorrect queue lengths
info: count=0,0, expect=0,20
ERROR: incorrect queue lengths
[FAIL]
