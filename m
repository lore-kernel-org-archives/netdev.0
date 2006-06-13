From: Mark Lord <lkml@rtr.ca>
Subject: Re: 2.6.17: networking bug??
Date: Tue, 13 Jun 2006 12:58:05 -0400
Message-ID: <448EEE9D.10105@rtr.ca>
References: <448EC6F3.3060002@rtr.ca> <448ECB09.3010308@rtr.ca> <448ED2FC.2040704@rtr.ca> <448ED9B3.8050506@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtr.ca ([64.26.128.89]:17897 "EHLO mail.rtr.ca")
	by vger.kernel.org with ESMTP id S932188AbWFMQ6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 12:58:07 -0400
To: Linux Kernel <linux-kernel@vger.kernel.org>
In-Reply-To: <448ED9B3.8050506@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

..
> The site www.everymac.com is still not browseable until
> setting /proc/sys/net/ipv4/tcp_window_scaling===0.
> 
> There's one other difference I see in the tcpdump traces.
> The first packets from each trace below show different
> values for "wscale".  The old (working) kernels use "wscale 2",
> whereas 2.6.17 uses "wscale 6".  In both cases, the value
> seen in /proc/sys/net/ipv4/tcp_adv_win_scale is 2.

Okay.  More progress here.  The calculation of the "wscale" values
is based on the "tcp_rmem" sysctl numbers.

The defaults for these *differ* between 2.6.16.18 and 2.6.17-rc*.

2.6.16: 4096    87380    174760  
2.6.17: 4096    87380   2097152

If I change the tcp_rmem setting on 2.6.17 to match the old value,
then the website www.everymac.com becomes accessible again:

echo 4096 87380 174760 > /proc/sys/net/ipv4/tcp_rmem

Looking at diffs between 2.6.16 and 2.6.17, I see a big rework
of the tcp_rmem code in linux/net/ipv4/tcp.c

Looks like something got broken there, or possibly the wscale
calculations have a bug that is only triggered by the new rmem values ??


