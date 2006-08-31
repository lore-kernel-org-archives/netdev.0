From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Unable to halt or reboot due to - unregister_netdevice: waiting for eth0.20 to become free. Usage count = 1
Date: Thu, 31 Aug 2006 17:17:20 +0200
Message-ID: <9a8748490608310817v7d722f88u167b5a84d0ff67e8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Mark Evans" <evansmp@uhura.aston.ac.uk>,
	"Fred N. van Kempen" <waltje@uWalt.NL.Mugnet.ORG>,
	"Ross Biro" <ross.biro@gmail.com>, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, "Ben Greear" <greearb@candelatech.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:5127 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1750988AbWHaPRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 11:17:22 -0400
Received: by wr-out-0506.google.com with SMTP id i28so220723wra
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2006 08:17:20 -0700 (PDT)
To: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've got a small problem with 2.6.18-rc5-git2.

I've got a vlan setup on eth0.20, eth0 does not have an IP.

When I attempt to reboot or halt the machine I get the following
message from the loop in net/core/dev.c::netdev_wait_allrefs() where
it waits for the ref-count to drop to zero.
Unfortunately the ref-count stays at 1 forever and the server never
gets any further.

  unregister_netdevice: waiting for eth0.20 to become free. Usage count = 1

I googled a bit and found that people have had similar problems in the
past and could work around them by shutting down the vlan interface
before the 'lo' interface. I tried that and indeed, it works.

Any idea how we can get this fixed?


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
