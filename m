From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: AW: Problem receiving multicast/promiscuous-mode with kernel.2.6.24
Date: Mon, 11 Feb 2008 11:18:05 -0800
Message-ID: <OF1D96C632.7939DCD3-ON882573EC.0068DFE8-882573EC.006A04EB@us.ibm.com>
References: <BA41E8A07B73A041948C2E3A4EF6239D062F0C@av-digital-exch.avdigital.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: "Reither Robert" <Robert.Reither@av-digital.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:55644 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836AbYBKTSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 14:18:31 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1BIEXKR015418
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 13:14:33 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1BJI9DB145150
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 12:18:10 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1BJI8sQ006728
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 12:18:08 -0700
In-Reply-To: <BA41E8A07B73A041948C2E3A4EF6239D062F0C@av-digital-exch.avdigital.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another relevant piece of information is what the socket is
bound to; "netstat -au" will tell you if you're bound to an address
that will match the incoming multicast packets.

If you suspect that the VLAN device is the problem, then it'd be
a good idea to try it on ordinary ethernet.

Re: imr_ifindex; using a "0" ifindex  and INADDR_ANY interface is valid,
but it usually doesn't make sense. What it means is "I don't care what
interface I join the group on". But you'll only receive multicasts
delivered to the group on the interface the kernel picks for you, which
often won't be the one you really want.

                                                +-DLS

