From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: 200 millisecond timeouts in TCP
Date: Fri, 4 Jun 2010 01:10:02 +0200
Message-ID: <20100603231002.GG6914@nuttenaction>
References: <AANLkTils4KHXwX79cLG6UvVOaDdddMqx-1tyUL3VtLQC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ivan Novick <novickivan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:45779 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752675Ab0FCXKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 19:10:06 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTils4KHXwX79cLG6UvVOaDdddMqx-1tyUL3VtLQC@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ivan Novick | 2010-06-03 15:37:24 [-0700]:

>Using tcpdump and systemtap I am seeing that sometimes retransmission
>of data is sent after waiting 200 milliseconds.  However sometimes
>retransmissions happen quicker.

Quicker as 200ms? Conservatively the minimum TCP RTO should be 1s (rfc2988),
Linux differs from this default and define the minimum RTO to 200ms:

#define TCP_RTO_MIN	((unsigned)(HZ/5))

Can you post the tcpdump traces where the relevant retransmission is recognizable?

>Also do you know if the timeout numbers for TCP are configurable parameters?

Some values are documented in Documentation/networking/ip-sysctl.txt, you can
find the relevant timer implementation in ipv4/tcp_input.c and the definition
of TCP_RTO_MIN in include/net/tcp.h.


Hagen Paul Pfeifer


-- 
Hagen Paul Pfeifer <hagen@jauu.net>  ||  http://jauu.net/
Telephone: +49 174 5455209           ||  Key Id: 0x98350C22
Key Fingerprint: 490F 557B 6C48 6D7E 5706 2EA2 4A22 8D45 9835 0C22
