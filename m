From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 20 Apr 2006 18:02:45 -0700
Message-ID: <44482F35.30208@hp.com>
References: <Pine.LNX.4.44.0604201329300.22544-100000@isotope.jf.intel.com>	<20060420213305.GK26746@pb15.lixom.net>	<c0a09e5c0604201514x16490b13v68644a24078b99de@mail.gmail.com> <20060420.173853.60273448.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andy.grover@gmail.com, olof@lixom.net, andrew.grover@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:11226 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S932198AbWDUBCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 21:02:46 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060420.173853.60273448.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: "Andrew Grover" <andy.grover@gmail.com>
> Date: Thu, 20 Apr 2006 15:14:15 -0700
> 
> 
>>First obviously it's a technology for RX CPU improvement so there's no
>>benefit on TX workloads. Second it depends on there being buffers to
>>copy the data into *before* the data arrives. This happens to be the
>>case for benchmarks like netperf and Chariot, but real apps using
>>poll/select wouldn't see a benefit,  Just laying the cards out here.
>>BUT we are seeing very good CPU savings on some workloads, so for
>>those apps (and if select/poll apps could make use of a
>>yet-to-be-implemented async net interface) it would be a win.
>>
>>I don't know what the breakdown is of apps doing blocking reads vs.
>>waiting, does anyone know?
> 
> 
> All the bandwidth benchmarks tend to block, real world servers (and
> most clients to some extent) tend to use non-blocking reads and
> poll/select except in some very limited cases and designs doing
> something like 1 thread per connection.

Another netperf2 option :) (not exported via configure though) if a 
certain define is set - look at recv_tcp_stream() in nettest_bsd.c - 
then netperf will call select() before it calls recv().

rick jones


