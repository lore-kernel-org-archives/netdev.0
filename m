From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 over Firewire
Date: Mon, 24 Dec 2012 02:09:15 +0900
Message-ID: <50D73ABB.4020800@linux-ipv6.org>
References: <50D49659.1000101@gmail.com> <50D4A219.7080807@linux-ipv6.org> <50D4ACFA.6040901@gmail.com> <50D4BD2F.7060006@linux-ipv6.org> <50D54ED9.6090908@gmail.com> <50D6BF6F.2030207@linux-ipv6.org> <50D6E73F.70301@gmail.com> <50D6F488.7060308@linux-ipv6.org> <50D7062D.8040901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36076 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751154Ab2LWRJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 12:09:18 -0500
In-Reply-To: <50D7062D.8040901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan Gatzka wrote:

> So may aim is to rewrite the LL address option both while transmitting and receiving IPv6 data on firewire. While transmitting, I append the required information, while receiving I cut away the the firewire specific stuff. So the upper layers will not see the firewire related information. Yes, that mangling also involves recalculation of the ICMPv6 checksum.

No, it is not enough.  For example, Signature Option of SEND
(RFC3971) takes link-layer address options into account.
If anything is happened to be altered, verification will
fail.

> Again, if I shall not mangle the ndisc packets in the driver I have to build RFC 3146 conformant packets in ndisc_build_skb(). But I see no (general) way to get the firewire specific information into the linux ndisc stuff. Of course I can add some if/else into ndisc_fill_addr_option() and ndisc_recv_na(). But then I have to pull a lot of firewire related stuff into the ndisc code.
>
> I think this makes no sense, especially because I need that firewire specific information in the firewire net driver to send correct firewire packets. Besides that, the IPv4 portion of the firewire net drivers does exactly the same with ARP packets what I want to do with IPv6 LL address options.

Please, please do not alter bits in your driver, to maintain
extensibility of protocols.

I am definitely okay to have firewire supporting stuff in
net/ipv6/ndisc.c.  Since we already have notification
mechanism, I don't think it will be large.

--yoshfuji
