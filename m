From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: kernel mode pppoe ppp if + ifb + mirred redirect, ethernet
 packets in ifb?!
Date: Wed, 14 Oct 2009 21:59:11 +0200
Message-ID: <20091014195911.GA3603@del.dom.local>
References: <200910130144.04910.denys@visp.net.lb>
 <20091014191155.GA3471@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:41749 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754659AbZJNT74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 15:59:56 -0400
Received: by fxm27 with SMTP id 27so175165fxm.17
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 12:59:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20091014191155.GA3471@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2009 at 09:11:55PM +0200, Jarek Poplawski wrote:
> Denys Fedoryschenko wrote, On 10/13/2009 12:44 AM:
> ...
> > As i understand, for pppoe case, he can just skip offset for ethernet and 
> > pppoe header, and he can filter by ip, or not?
> > Current way is maybe better, cause someone who want to count everything with 
> > ethernet and pppoe headers - can, and who want without - also can (by setting 
> > offset , just a bit more difficult.
> > 
> > Like 
> > /sbin/tc filter add dev eth1 protocol 0x8864  parent 2:0 prio 1 u32 \
> > match u32 0x$IPREMOTE_HEX 0xffffffff at 24 flowid 2:$ID
> > (found in LARTC)
> 
> Maybe I miss something, but generally (for IP, TCP etc. matches) it
> should work "as usual". I think you and those other users you quoted
> were mislead by that tcpdump on ifb. Probably in some configs you
> might needed this 'protocol 0x8864' or 'protocol all'. You should
> see it on ppp's tcpdump then, like yours:

Hmm... Of course, like yours, where we can't see it ;-)
so 'protocol ip' is enough.

> 
> > PPPoE_146 ~ # tcpdump -ni ppp0 -e -vvv -s 1500 -c 4
> > tcpdump: WARNING:
> > tcpdump: listening on ppp0, link-type LINUX_SLL (Linux cooked), capture size 
> > 1500 bytes
> > 17:03:17.015598 Out ethertype IPv4 (0x0800), length 68: (tos 0x0, ttl 111, id 

BTW, let's note this 'protocol 0x8864' was used with dev eth1, so it's
a different case.

Jarek P.
