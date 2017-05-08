From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 net-next 08/10] net/ncsi: Support NCSI packet
 generation
Date: Mon, 8 May 2017 02:56:32 +0200
Message-ID: <20170508005632.GF27709@lunn.ch>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-9-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170503125254.GF8029@lunn.ch>
 <20170504063156.GA7620@gwshan>
 <20170504120035.GQ8029@lunn.ch>
 <20170508002512.GA6012@gwshan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, joe@perches.com, kubakici@wp.pl,
        f.fainelli@gmail.com, davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52502 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750948AbdEHA4g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 7 May 2017 20:56:36 -0400
Content-Disposition: inline
In-Reply-To: <20170508002512.GA6012@gwshan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I need to dig how libpcap receives packets. It's appreciated if you
> can give some hints about that. However, I don't see the benefit to
> receive packets by libpcap, could you claim?

The base interface should already be doing it for you. Try it! Run
tcpdump or wireshark and you should see the NCSI packets going
out/coming in. Look for the ethertype. Neither tcpdump or wireshark
appear to have dissectors for NCSI, but it should be simple to
write. I've written them before, and it is easy.

Doing it in userspace will give you a much nice environment to work
in. Wireshark can link the response to the request, do a much more
detailed decode than what you want to do in kernel space, and in
general it is safer. Wrongly decoding and printing protocols in kernel
space can lead to a remote kernel vulnerability. Getting it wrong in
user space 'just' allows a remote hack of a user account.

     Andrew
