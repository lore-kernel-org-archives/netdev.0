From: Ben Greear <greearb@candelatech.com>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
Date: Wed, 23 Jan 2013 20:26:28 -0800
Message-ID: <5100B7F4.2050505@candelatech.com>
References: <50FDADF4.3060601@candelatech.com>  <50FDDE35.7070806@candelatech.com>  <1358829606.3464.3151.camel@edumazet-glaptop>  <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>  <1358875020.3464.4006.camel@edumazet-glaptop>  <1358875607.3464.4020.camel@edumazet-glaptop>  <50FF102F.2050008@candelatech.com> <50FF4BC9.1060206@candelatech.com>  <5100785D.8040101@candelatech.com>  <1358985688.12374.1247.camel@edumazet-glaptop>  <51007CA8.2050105@candelatech.com>  <1358987031.12374.1276.camel@edumazet-glaptop>  <51008294.2010201@candelatech.com>  <1358988358.12374.1303.camel@edumazet-glaptop>  <51008598.4000603@candelatech.com>  <1358989242.12374.1323.camel@edumazet-glaptop>  <51008900.2010803@candelatech.com>  <1358989843.12374.1334.camel@edumazet-glaptop> <1358991906.1
 2374.1356.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48816 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884Ab3AXE0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 23:26:36 -0500
In-Reply-To: <1358991906.12374.1356.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2013 05:45 PM, Eric Dumazet wrote:
> On Wed, 2013-01-23 at 17:10 -0800, Eric Dumazet wrote:
>
>> Excellent, thats the bug.
>>
>> I'll send a fix asap, thanks !
>
> loopback device doesnt have a qdisc, and unsets IFF_XMIT_DST_RELEASE
>
> Its hard to believe such an old bug never hit us in the past.
>
> Probably because most of the time, the packet given to netif_rx() is
> immediately processed (and loopback device is hard wired ?)

I'll test this in the morning...one thing, maybe it's worth adding
a WARN_ON in netif_rx() in case there are other bugs of
this nature?

The dst objects are also garbage collected, so they have a fairly
long valid-ish lifetime after they are logically freed.  That might
be part of why it was so hard to reproduce the bug...

Thanks again for all the help on this bug!  Hopefully it will now
be well and truly squashed.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
