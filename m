From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: where change events in epoll_wait(), and who notify an epoll event?
Date: Tue, 29 Jul 2008 17:10:23 +0400
Message-ID: <20080729131023.GA26846@2ka.mipt.ru>
References: <15da71430807281854v3e7c2536hd4e709a9a5dc7bb6@mail.gmail.com> <20080729063909.GB7009@2ka.mipt.ru> <15da71430807290538l6f702303hfa57665314c89ff1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: cpusoft <cpusoft@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:58083 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753154AbYG2NKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 09:10:20 -0400
Content-Disposition: inline
In-Reply-To: <15da71430807290538l6f702303hfa57665314c89ff1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Jul 29, 2008 at 08:38:28PM +0800, cpusoft (cpusoft@gmail.com) wrote:
> thanks alot. however, i still  wonder who call the driever's
> wake_up(&private_wait_queue_head)?

Driver itself. For example from interrupt. In network it is softirq
context via netif_receive_skb(), which in turn will call network
protocol receiving function (for example ip_rcv), which in turn will
call transport layer function (like udp_rcv), which will locate a
socket, queue skb there and call sk->sk_data_ready() callback, which is
a wake_up(&private_wait_queue_head) for the sockets.

-- 
	Evgeniy Polyakov
