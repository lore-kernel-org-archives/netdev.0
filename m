From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC/PATCH 0/3] UDP memory usage accounting
Date: Fri, 21 Sep 2007 16:58:43 +0400
Message-ID: <20070921125843.GA15810@2ka.mipt.ru>
References: <46F3B67F.4030007@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, haoki@redhat.com,
	=?utf8?B?5ZCJ6JekIOiLseaYjg==?= <yoshfuji@linux-ipv6.org>
To: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45035 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198AbXIUM7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 08:59:12 -0400
Content-Disposition: inline
In-Reply-To: <46F3B67F.4030007@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Fri, Sep 21, 2007 at 09:18:07PM +0900, Satoshi OSHIMA (satoshi.oshima.fk@hitachi.com) wrote:
> This patch set try to introduce memory usage accounting for
> UDP(currently ipv4 only).
> 
> Currently, memory usage of UDP can be observed as the sam of
> usage of tx_queue and rx_queue. But I believe that the system
> wide accounting is usefull when heavy loaded condition.
> 
> In the next step, I would like to add memory usage quota
> for UDP to avoid unlimited memory consumption problem
> under DDOS attack.

Could you please desribed such attack in more details?
Each UDP socket has its queue length which can not be exceeded
(roughly), no new sockets are created when remote side sends a packet
(like after special steps in TCP), so where is possibility to eat all
the mem?

> This patch set is for 2.6.23-rc7.

I seriously doubt you want to put udp specific hacks and zillions of
atomic ops all around the code just to know exact number of bytes eaten
for UDP.

Please use udp specific code (like udp_sendmsg()) for proper accounting
if you need that, but not hacks in generic ip code.

-- 
	Evgeniy Polyakov
