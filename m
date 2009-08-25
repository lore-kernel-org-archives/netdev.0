From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2 / tbf with large burst seems broken again
Date: Tue, 25 Aug 2009 22:03:06 +0200
Message-ID: <20090825200306.GA3020@ami.dom.local>
References: <200908251416.13888.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:64817 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755616AbZHYUDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 16:03:16 -0400
Received: by bwz19 with SMTP id 19so2130961bwz.37
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 13:03:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200908251416.13888.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko wrote, On 08/25/2009 01:16 PM:
...
> But this one maybe will overflow because of limitations in iproute2.
> 
> PPoE_146 ~ # ./tc -s -d qdisc show dev ppp13
> qdisc tbf 8004: root rate 96000bit burst 797465b/8 mpu 0b lat 275.4s
>  Sent 82867 bytes 123 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> qdisc ingress ffff: parent ffff:fff1 ----------------
>  Sent 506821 bytes 1916 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> 
> So maybe all of that just wrong way of using TBF.

I guess so; I've just recollected you described it some time ago. If
it were done only with TBF it would mean very large surges with line
speed and probably a lot of drops by ISP. Since you're ISP, you
probably drop this with HTB or something (then you should mention it
describing the problem) or keep very long queues which means great
latencies. Probably there is a lot of TCP resending btw. Using TBF
with HTB etc. is considered wrong idea anyway. (But if it works for
you shouldn't care.)

> At same time this means, if HTB and policers in filters done same way, that 
> QoS in Linux cannot do similar to squid delay pools feature:
> 
> First 10Mb give with 1Mbit/s, then slow 64Kbit/s. If user use less than 64K - 
> recharge with that unused bandwidth a "10 Mb / 1Mbit bucket".

Could you remind me why HFSC can't do something similar for you?

Jarek P.
