From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: Bug in order of multiple IPv6 addresses per interface? Newest
 added one is preferred in difference to IPv4
Date: Mon, 21 Aug 2006 19:42:53 +0900 (JST)
Message-ID: <20060821.194253.07794662.yoshfuji@linux-ipv6.org>
References: <44E94653.1040002@bieringer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:65298 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751847AbWHUKlI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 06:41:08 -0400
To: pb@bieringer.de
In-Reply-To: <44E94653.1040002@bieringer.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <44E94653.1040002@bieringer.de> (at Mon, 21 Aug 2006 07:36:19 +0200), Peter Bieringer <pb@bieringer.de> says:

> In IPv6, the behavior is completly different:
> 
> # ip -6 addr show dev eth0  |grep -w inet6 |grep -w global
>     inet6 2001:db8:0:1::11/64 scope global
> 
> # ip -6 addr add 2001:db8:0:1::253/64 dev eth0
> 
> # ip -6 addr show dev eth0  |grep -w inet6 |grep -w global
>     inet6 2001:db8:0:1::253/64 scope global   <- #2 !!!!
>     inet6 2001:db8:0:1::11/64 scope global    <- #1
> 
> So the last added on is now the first in list. Also, it gets no
> "secondary" flag and "ip" doesn't even support this flag.

IPv6 does not have secondary flag. We even reuse that for
IPv6 temporary addresses.

> And the worse thing is that the first one in list (= last added one) is
> now used as default for outgoing connections. Can be easily tested using
> "ping6".
:
> Is this a bug (I hope so) or a (undocumented?) feature?

An implementation decision.
I do not favor changing this so far.

--yoshfuji
