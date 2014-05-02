From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets between two
 guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy" series.
Date: Fri, 02 May 2014 08:35:33 -0700
Message-ID: <1399044933.29914.242.camel@edumazet-glaptop2.roam.corp.google.com>
References: <395225650.20140430124506@eikelenboom.it>
	 <536250F9.7060405@citrix.com> <1967602892.20140501160513@eikelenboom.it>
	 <53626563.8010404@citrix.com> <1046603646.20140501174053@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	xen-devel@lists.xen.org, Neal Cardwell <ncardwell@google.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:64930 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080AbaEBPfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 11:35:53 -0400
Received: by mail-ig0-f174.google.com with SMTP id h18so2022269igc.1
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 08:35:53 -0700 (PDT)
In-Reply-To: <1046603646.20140501174053@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-01 at 17:40 +0200, Sander Eikelenboom wrote:

> Yesterday i tried to get packetdrill (https://code.google.com/p/packetdrill/) to 
> work to see if i could reproduce with one of it's tests, but didn't get the 
> client server stuff working. It seems it has helped with finding and fixing 
> previous kernel networking bugs.

If you use recent net-next kernel, you need a packetdrill patch, Neal
might submit it shortly on packetdrill repo.

packetdrill currently does not consume the packets sent on the tun
device, so this triggers the new [1] TCP stack behavior detecting packet
did not yet leaved the host.

[1] :
( http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=1f3279ae0c13cd742731726b0ed195d5f09b14e4 )
