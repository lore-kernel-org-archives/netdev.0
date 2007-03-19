From: David Miller <davem@davemloft.net>
Subject: Re: many sockets, slow sendto
Date: Mon, 19 Mar 2007 16:16:11 -0700 (PDT)
Message-ID: <20070319.161611.70218081.davem@davemloft.net>
References: <E1HObHK-0000WB-00@osiris.swi.hu>
	<20070306182039.GJ25760@galon.ev-en.org>
	<45FF185B.4070007@fw.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: baruch@ev-en.org, netdev@vger.kernel.org
To: zacco@fw.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58374
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965570AbXCSXQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 19:16:20 -0400
In-Reply-To: <45FF185B.4070007@fw.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zacco <zacco@fw.hu>
Date: Tue, 20 Mar 2007 00:10:19 +0100

> As you recommended, I used oprofile and it turned out that the 
> __udp4_lib_lookup function spent most of the time. There is a udp hash 
> table and the sockets are sought based on the 7 LSBs of the destination 
> port number. So what happened is now quite obvious: I had many thousands 
> of sockets, all with the same destination port, thus linked in the same 
> slot of this hash table. I tried using different ports and it
> was much faster then.

There isn't much we can do here.  I bet your destination address
is unchanging just like your destination ports.

UDP apps can and do bind to specific destination addresses and
ports, but the source side is usually wild-carded.

Are both the source address and port fully specified for your
sockets?  Maybe we can do something using if that's the case...
