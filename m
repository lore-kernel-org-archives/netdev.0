From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: raw sockets rewriting IP ID in rare cases.
Date: Sat, 14 Aug 2010 22:35:32 -0700 (PDT)
Message-ID: <20100814.223532.242143460.davem@davemloft.net>
References: <201008131307.38381.morgon.j.kanter@dartmouth.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: morgon.j.kanter@dartmouth.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44886
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752524Ab0HOFfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Aug 2010 01:35:14 -0400
In-Reply-To: <201008131307.38381.morgon.j.kanter@dartmouth.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Morgon J. Kanter" <morgon.j.kanter@dartmouth.edu>
Date: Fri, 13 Aug 2010 13:07:38 -0400

> I have stumbled across what I think is a rare bug in the raw socket mechanism 
> of the kernel. When attempting to send a certain packet with an IP ID of zero 
> from a raw socket created with the call "socket(AF_INET, SOCK_RAW, 
> IPPROTO_RAW)", the kernel will modify the IP ID field and update the checksum. 
> It only seems to do it with this specific packet for some reason, similar 
> packets with an IP ID of zero do not get so mangled.

Even when using hdrinclude mode of RAW ipv4 sockets, if you specify
a zero ID field, the kernel will fill it in with the usual value.

It is expected behavior.

If you want the kernel to leave your ID field alone, provide a
non-zero one.
