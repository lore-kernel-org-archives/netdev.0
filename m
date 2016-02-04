From: Sorin Manolache <sorinm@gmail.com>
Subject: Re: Fw: [Bug 111771] New: deadlock in ppp/l2tp
Date: Thu, 4 Feb 2016 02:32:48 +0100
Message-ID: <56B2AA40.5090601@gmail.com>
References: <20160203110431.7b878a4f@samsung9>
 <20160203171401.GC1267@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37129 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197AbcBDBc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 20:32:58 -0500
Received: by mail-wm0-f51.google.com with SMTP id l66so96114010wml.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 17:32:57 -0800 (PST)
In-Reply-To: <20160203171401.GC1267@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-02-03 18:14, Guillaume Nault wrote:
> On Wed, Feb 03, 2016 at 11:04:31AM +1100, Stephen Hemminger wrote:
>> Please excuse URL mangling, my bugzilla address appears to route through
>> stupid corporate firewall.
>>
>
> Sorin, it seems like one of your L2TP tunnels is routed to one of its upper PPP
> devices. Most likely, the peer address of the PPP device is also the address of
> the remote L2TP tunnel endpoint. So L2TP packets are sent back to the upper PPP
> device, instead of leaving through the physical interface.

Thank you. You are right. There's a host route to the peer over the ppp0 
interface in the routing table. I don't know how it gets there. I've 
checked the source code of pppd and no such route is added for kernels 
newer than 2.1.16. I've grepped /etc for "route" in order to detect a 
"post-up" script that would add that route. Nothing. I've double-checked 
by executing strace on xl2tpd and its children (i.e. pppd and the 
initialisation scripts) and I couldn't find any ioctl SIOCADDRT. So it's 
a total mystery for me where that route comes from. Could it come from 
the kernel?

I've found this 9-year-old bug report: 
https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=444180. I've adopted 
the strategy that the comment proposes: delete the route in an post-up 
script.

Thanks again.

Best regards,
Sorin
