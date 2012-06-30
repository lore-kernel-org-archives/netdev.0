From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: problems with iproute2 m_xt again...
Date: Sat, 30 Jun 2012 15:17:55 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1206301512520.27385@frira.zrqbmnf.qr>
References: <20120630120939.GA18134@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: shemminger@vyatta.com,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>, YANG Zhe <yangzhe1990@gmail.com>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([5.9.24.206]:33103 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753820Ab2F3N2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2012 09:28:11 -0400
In-Reply-To: <20120630120939.GA18134@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 2012-06-30 14:09, Andreas Henriksson wrote:

>Hello!
>
>Mailing you in hope that you could help out with the xt module of iproute2 tc
>once more, as you've done in the past.... It seems to be broken again. sigh.
>
>amd64:~# iptables -nL | grep test
>Chain test (0 references)
>amd64:~# tc filter add dev fon parent ffff: protocol ip prio 10 u32 action xt -j test
> failed to find target test
>
>bad action parsing
>parse_action: bad value (3:xt)!
>Illegal "action"
>amd64:~#

Looks more like a syntax error. I don't see any functions of m_xt.so 
being ever called (and it only has two).

>And maybe even more interesting is when I try to use a built-in chain 
>like DROP:

DROP is not a chain, but a verdict.

>amd64:~# tc filter add dev fon parent ffff: protocol ip prio 10 u32 
>action xt -j DROP
>tablename: mangle hook: NF_IP_PRE_ROUTING
>Segmentation fault

Rather than a segfault, this gets me "bad action parsing" in 
iproute2-3.4.0 as well.
