From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 13:33:15 -0800
Message-ID: <1454103195.7627.76.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160129180651.GA17127@oracle.com>
	 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160129.110634.1678121731419241040.davem@davemloft.net>
	 <1454096250.7627.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160129194434.GC17127@oracle.com>
	 <1454097696.7627.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAKgT0UdXBHocMwdcQHHd5bGMUofEH6ENox=Jw_vLEn3kMonmhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34196 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755238AbcA2VdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 16:33:18 -0500
Received: by mail-pa0-f50.google.com with SMTP id uo6so48136583pac.1
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 13:33:17 -0800 (PST)
In-Reply-To: <CAKgT0UdXBHocMwdcQHHd5bGMUofEH6ENox=Jw_vLEn3kMonmhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-29 at 13:16 -0800, Alexander Duyck wrote:

> It has to be something recent.  I know back when I wrote the code I
> tested it on a few different architectures and had to add a few bits
> in __skb_get_poff so that it would read doff as a u8 instead of
> bitfield in a u32.
> 
> Looking at the code it seems like this should be an easy fix.  Just
> swap the two lines that acquire and test the flow label with the check
> for dissector_uses_key(... _KEY_FLOW_LABEL).  Then ixgbe will stop
> trying to grab flow labels.

Note that if we properly align headers, we also align TCP/UDP payload.

Meaning that copying data in recvmsg() is likely faster in some cpus.
(The ones having NET_IP_ALIGN set to 2 presumably)
