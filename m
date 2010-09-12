From: David Miller <davem@davemloft.net>
Subject: Re: pimreg zombies
Date: Sun, 12 Sep 2010 12:17:13 -0700 (PDT)
Message-ID: <20100912.121713.189706279.davem@davemloft.net>
References: <2bpal7-l68.ln1@chipmunk.wormnet.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alex@digriz.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38886
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752211Ab0ILTQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Sep 2010 15:16:55 -0400
In-Reply-To: <2bpal7-l68.ln1@chipmunk.wormnet.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Clouter <alex@digriz.org.uk>
Date: Sat, 4 Sep 2010 22:12:34 +0100

> I am writing a multicast pim daemon and noticed that if I call 
> setsockopt(MRT_ADD_VIF), also occurs for IPv6 too, incorrectly on a 
> socket established with socket(AF_INET, SOCK_RAW, IPPROTO_PIM)[1] then 
> when the application quits I have zombie pimreg (and pimreg6) interfaces 
> that can only be disposed of with a reboot.

pimreg interfaces can only be instantiated and removed from userspace
by using the appropriate MRT_*.  So you can get rid of these
interfaces by using an appropriate MRT_DEL_VIF call on an IPPROTO_PIM
socket.

They are not automatically removed by the closing of that userland
socket.
