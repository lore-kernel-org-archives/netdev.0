From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2: adding /128 address to sit interface borks
Date: Sat, 27 Feb 2010 08:23:56 -0800
Message-ID: <20100227082356.67b7c0a3@nehalam>
References: <alpine.LSU.2.00.0907101402430.21999@fbirervta.pbzchgretzou.qr>
	<20090710082731.0b06c0eb@nehalam>
	<alpine.LSU.2.01.1002271601210.29398@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57952 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968514Ab0B0QYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 11:24:09 -0500
In-Reply-To: <alpine.LSU.2.01.1002271601210.29398@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 27 Feb 2010 16:03:36 +0100 (CET)
Jan Engelhardt <jengelh@medozas.de> wrote:

> 
> On Friday 2009-07-10 17:27, Stephen Hemminger wrote:
> >On Fri, 10 Jul 2009 14:05:01 +0200 (CEST)
> >Jan Engelhardt <jengelh@medozas.de> wrote:
> >
> >> it's impossible to do this, and the error message does not say why 
> >> that is so. No word in dmesg either.
> >> 
> >> # ip a a fc00::49/128 peer fc00::7 dev sit7
> >> RTNETLINK answers: Invalid argument
> >
> >You will need to walk through the path in the kernel.
> >In worst case, it means adding kernel printk's.
> >
> >Then if you want to be nice, make a patch to ipaddr.c in iproute
> >utilities so command line can find the error before passing to
> >kernel and give a nice error :-)
> 
> The issue here was that the peer is encoded using the broadcast
> field, and since IPv6 has no broadcast, it was rejected by
> the kernel. The error messages really need to be improved.
> 
> This year also came an article about that,
> http://lwn.net/Articles/374794/

The article overlooks the fact that netlink is a message based interface.
There is no reason that the response message can't be extended to add
additional sections to give more detailed answer. The issues are:
  * no infrastructure for this (message format, helpers, etc)
  * tedious effort to annotate all the existing error returns
  * update to command and library

The extended error reports could even be a kernel config option so the
embedded and those worried about space would not have to have it.

-- 
