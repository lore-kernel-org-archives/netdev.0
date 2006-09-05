From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH][RFC] Re: high latency with TCP connections
Date: Tue, 05 Sep 2006 10:55:16 -0700
Message-ID: <44FDBA04.3080104@hp.com>
References: <20060830100734.GA22235@isil.ipib.msu.ru> <20060904160045.GA15599@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Vodomerov <alex@sectorb.msk.ru>, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:56494 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S965232AbWIERzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 13:55:19 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060904160045.GA15599@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov wrote:
> Hello!
> 
> 
>>Some people reported that this program runs in 9.997 sec when run on
>>FreeBSD.
> 
> 
> Try enclosed patch. I have no idea why 9.997 sec is so magic, but I
> get exactly this number on my notebook. :-)
> 
> Alexey
> 
> =================
> 
> This patch enables sending ACKs each 2d received segment.
> It does not affect either mss-sized connections (obviously) or connections
> controlled by Nagle (because there is only one small segment in flight).
> 
> The idea is to record the fact that a small segment arrives
> on a connection, where one small segment has already been received
> and still not-ACKed. In this case ACK is forced after tcp_recvmsg()
> drains receive buffer.
> 
> In other words, it is a "soft" each-2d-segment ACK, which is enough
> to preserve ACK clock even when ABC is enabled.

Is this really necessary?  I thought that the problems with ABC were in 
trying to apply byte-based heuristics from the RFC(s) to a 
packet-oritented cwnd in the stack?

rick jones
