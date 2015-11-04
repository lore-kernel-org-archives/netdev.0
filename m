From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB, HFSC, PIE, FIFO stuck on 2.4Gbit on default values
Date: Tue, 03 Nov 2015 21:02:59 -0800
Message-ID: <1446613379.4184.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <14bd7629199800f798c8ab932e0285d3@visp.net.lb>
	 <1446577894.23275.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <907cb54c0a27beed12381247ba29bca5@visp.net.lb>
	 <1446580156.23275.74.camel@edumazet-glaptop2.roam.corp.google.com>
	 <f970215bd46efe3ea3dc5c7fccfa0509@visp.net.lb>
	 <1446585826.23275.78.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0394a0a8c8f65e367a596274719ed759@visp.net.lb>
	 <1446611317.4184.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <f471b1af41bdbe09d214b029dc75221e@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33526 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbbKDFDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 00:03:00 -0500
Received: by pabfh17 with SMTP id fh17so40901397pab.0
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 21:03:00 -0800 (PST)
In-Reply-To: <f471b1af41bdbe09d214b029dc75221e@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-04 at 06:49 +0200, Denys Fedoryshchenko wrote:
> Tested now, can be reproduced on 4.3 as well.
> What is interesting, if i enable tso alone, and leave gso/gro off - it 
> is working fine. gso+gro on, tso off - fine also.
> But if i enable them all together - i trigger the bug.

If GRO is disabled, no TSO packet ever arrive to the NIC to trigger the
TSO bug ;) So leaving TSO on or off does not really matter.

If GRO is enabled, and TSO disabled, core networking stack will
'segment' the GRO packets right after qdisc dequeue, before giving to
the NIC individual (non TSO) segments.

It enables skb->xmit_more processing on e1000e so you should get better
performance, even if TSO happens to be broken on e1000e
