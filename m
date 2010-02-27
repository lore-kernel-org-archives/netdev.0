From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: iproute2: adding /128 address to sit interface borks
Date: Sat, 27 Feb 2010 16:03:36 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1002271601210.29398@obet.zrqbmnf.qr>
References: <alpine.LSU.2.00.0907101402430.21999@fbirervta.pbzchgretzou.qr> <20090710082731.0b06c0eb@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:55810 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964958Ab0B0PDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 10:03:38 -0500
In-Reply-To: <20090710082731.0b06c0eb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2009-07-10 17:27, Stephen Hemminger wrote:
>On Fri, 10 Jul 2009 14:05:01 +0200 (CEST)
>Jan Engelhardt <jengelh@medozas.de> wrote:
>
>> it's impossible to do this, and the error message does not say why 
>> that is so. No word in dmesg either.
>> 
>> # ip a a fc00::49/128 peer fc00::7 dev sit7
>> RTNETLINK answers: Invalid argument
>
>You will need to walk through the path in the kernel.
>In worst case, it means adding kernel printk's.
>
>Then if you want to be nice, make a patch to ipaddr.c in iproute
>utilities so command line can find the error before passing to
>kernel and give a nice error :-)

The issue here was that the peer is encoded using the broadcast
field, and since IPv6 has no broadcast, it was rejected by
the kernel. The error messages really need to be improved.

This year also came an article about that,
http://lwn.net/Articles/374794/
