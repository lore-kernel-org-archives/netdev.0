From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: "ip neigh show" not showing arp cache entries?
Date: Tue, 18 Dec 2007 08:52:01 -0600
Message-ID: <4767DE91.9060803@nortel.com>
References: <E1J4TCz-0005L8-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, dada1@cosmosbay.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:56151 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755282AbXLROxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 09:53:09 -0500
In-Reply-To: <E1J4TCz-0005L8-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Chris Friesen <cfriesen@nortel.com> wrote:
> 
>>However, if I specifically try to print out one of the missing entries, 
>>it shows up:
>>
>>root@typhoon-base-unit0:/root> /tmp/ip neigh show 192.168.24.81
>>192.168.24.81 dev bond2 lladdr 00:01:af:14:e9:8a REACHABLE
> 
> 
> What about
> 
> 	ip -4 neigh show

Looks like that did it.  Why does specifying the family make a difference?

root@typhoon-base-unit0:/root> ip neigh show
10.41.18.1 dev eth6 lladdr 00:00:5e:00:01:01 STALE
172.24.137.0 dev bond0 lladdr 00:c0:8b:08:e4:88 REACHABLE
172.24.0.9 dev bond0 lladdr 00:07:e9:41:4b:b4 REACHABLE
10.41.18.101 dev eth6 lladdr 00:0e:0c:5e:95:bd REACHABLE
172.24.0.11 dev bond0 lladdr 00:03:cc:51:06:5e STALE
172.24.132.1 dev bond0 lladdr 00:01:af:14:e9:88 REACHABLE
172.24.0.15 dev bond0 lladdr 00:0e:0c:85:fd:d2 STALE
172.24.0.3 dev bond0 lladdr 00:01:af:14:c8:cc REACHABLE
172.24.0.5 dev bond0 lladdr 00:01:af:15:e0:6a STALE

root@typhoon-base-unit0:/root> ip -4 neigh show
192.168.24.81 dev bond2 lladdr 00:01:af:14:e9:8a REACHABLE
172.24.132.2 dev bond0  FAILED
172.24.136.0 dev bond0 lladdr 00:c0:8b:07:b3:7e REACHABLE
10.41.18.1 dev eth6 lladdr 00:00:5e:00:01:01 STALE
172.24.137.0 dev bond0 lladdr 00:c0:8b:08:e4:88 REACHABLE
172.24.0.9 dev bond0 lladdr 00:07:e9:41:4b:b4 REACHABLE
10.41.18.101 dev eth6 lladdr 00:0e:0c:5e:95:bd REACHABLE
172.24.0.11 dev bond0 lladdr 00:03:cc:51:06:5e STALE
172.24.132.1 dev bond0 lladdr 00:01:af:14:e9:88 REACHABLE
172.24.0.15 dev bond0 lladdr 00:0e:0c:85:fd:d2 STALE
172.24.0.3 dev bond0 lladdr 00:01:af:14:c8:cc REACHABLE
172.24.0.5 dev bond0 lladdr 00:01:af:15:e0:6a STALE

Chris
