From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: 200 millisecond timeouts in TCP
Date: Thu, 3 Jun 2010 18:13:19 -0700
Message-ID: <A86A7D0E-F304-4322-8204-8F352E67D4E2@earthlink.net>
References: <AANLkTils4KHXwX79cLG6UvVOaDdddMqx-1tyUL3VtLQC@mail.gmail.com> <20100603231002.GG6914@nuttenaction>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Ivan Novick <novickivan@gmail.com>, netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:36276
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753403Ab0FDBNY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jun 2010 21:13:24 -0400
In-Reply-To: <20100603231002.GG6914@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 3, 2010, at 4:10 PM, Hagen Paul Pfeifer wrote:

> * Ivan Novick | 2010-06-03 15:37:24 [-0700]:
> 
>> Using tcpdump and systemtap I am seeing that sometimes retransmission
>> of data is sent after waiting 200 milliseconds.  However sometimes
>> retransmissions happen quicker.
> 
> Quicker as 200ms? Conservatively the minimum TCP RTO should be 1s (rfc2988),
> Linux differs from this default and define the minimum RTO to 200ms:
> 
> #define TCP_RTO_MIN	((unsigned)(HZ/5))
> 
> Can you post the tcpdump traces where the relevant retransmission is recognizable?
> 
>> Also do you know if the timeout numbers for TCP are configurable parameters?
> 
> Some values are documented in Documentation/networking/ip-sysctl.txt, you can
> find the relevant timer implementation in ipv4/tcp_input.c and the definition
> of TCP_RTO_MIN in include/net/tcp.h.
> 
> 
> Hagen Paul Pfeifer
> 
> 
> -- 
> Hagen Paul Pfeifer <hagen@jauu.net>  ||  http://jauu.net/
> Telephone: +49 174 5455209           ||  Key Id: 0x98350C22
> Key Fingerprint: 490F 557B 6C48 6D7E 5706 2EA2 4A22 8D45 9835 0C22

Group, from page 7 of the Linux TCP Congestion Control doc.

"Linux TCP deviates from the IETF specification by al- lowing a minimum limit of 200 ms for the RTO."

Mitchell Erblich