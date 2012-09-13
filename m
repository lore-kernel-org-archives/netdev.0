From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GRO aggregation
Date: Thu, 13 Sep 2012 10:11:05 +0200
Message-ID: <1347523865.13103.1423.camel@edumazet-glaptop>
References: <504F4063.9030706@mellanox.com>
	 , <1347388396.13103.658.camel@edumazet-glaptop>
	 <36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com>
	 , <1347390113.13103.660.camel@edumazet-glaptop>
	 <36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com>
	 <1347392132.13103.663.camel@edumazet-glaptop>
	 <505054AE.9040901@mellanox.com>
	 <1347442394.13103.703.camel@edumazet-glaptop> <50509F30.30402@mellanox.com>
	 <5050B6FF.5050002@hp.com> <5050B9B2.5070107@mellanox.com>
	 <5050BDB5.8090200@hp.com>  <50517F01.9050501@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shlomo Pongartz <shlomop@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43637 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416Ab2IMILM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 04:11:12 -0400
Received: by bkwj10 with SMTP id j10so346867bkw.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 01:11:09 -0700 (PDT)
In-Reply-To: <50517F01.9050501@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-13 at 09:36 +0300, Shlomo Pongartz wrote:

> The thing is that napi_complete calls napi_gro_flush so this pose a 
> limit on the aggregation.
> However when I count the number of packets received until this routine 
> is been called, I get a number,
> which is bigger then what I see with tcpdump, and this number is less 
> than what is expected if the limit is 64K.
> So I what to know what can I do in order to improve things, e.g. 
> allocate the skb differently.
> 

I already answered to this question somehow.

MAX_SKB_FRAGS is 16

skb_gro_receive() will return -E2BIG once this limit is hit.

If you use a MSS = 100 (instead of MSS = 1460), then GRO skb will
contain only at most 1700 bytes, but TSO packets can still be 64KB, if
the sender NIC can afford it (some NICS wont work quite well)

We are not going to change skb allocations to get bigger GRO packets,
for several reasons.

Once of the reason is inherent to TCP protocol, because only one ACK is
sent in response to a GRO packet.

In your LAN, feel free to use bigger MTU to reach this 64KB magical
value you seem to desperately seek.
