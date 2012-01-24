From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next] net: flow_dissector.c missing include linux/export.h
Date: Tue, 24 Jan 2012 15:59:00 -0500
Message-ID: <CAP=VYLpGk5+626QT31-nUkSJjay6ZnY8APxLfD-MUkqCJMxYng@mail.gmail.com>
References: <1327420643.4549.113.camel@probook>
	<1327421731.7231.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAP=VYLr-28ZSG7tURdGbp5nG4JdOMh_GZfv0HnCxpjv+GggMLA@mail.gmail.com>
	<20120124.155135.1784877918701583546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, jdb@comx.dk, netdev@vger.kernel.org,
	sfr@canb.auug.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:34169 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756543Ab2AXU7C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 15:59:02 -0500
Received: by ghrr11 with SMTP id r11so1065820ghr.19
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 12:59:01 -0800 (PST)
In-Reply-To: <20120124.155135.1784877918701583546.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2012 at 3:51 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Tue, 24 Jan 2012 14:44:21 -0500
>
>> On Tue, Jan 24, 2012 at 11:15 AM, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
>>> Le mardi 24 janvier 2012 =E0 16:57 +0100, Jesper Dangaard Brouer a =
=E9crit :
>>>> The file net/core/flow_dissector.c seems to be missing
>>>> including linux/export.h.
>>>>
>>>> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
>>>> ---
>>>> =A0net/core/flow_dissector.c | =A0 =A01 +
>>>> =A01 files changed, 1 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>>>> index 0985b9b..a225089 100644
>>>> --- a/net/core/flow_dissector.c
>>>> +++ b/net/core/flow_dissector.c
>>>> @@ -1,4 +1,5 @@
>>>> =A0#include <linux/skbuff.h>
>>>> +#include <linux/export.h>
>>>> =A0#include <linux/ip.h>
>>>> =A0#include <linux/ipv6.h>
>>>> =A0#include <linux/if_vlan.h>
>>>
>>>
>>> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>>>
>>> Hmm, not sure how you found this, since export.h is included from
>>> linux/netdevice.h (via net/netprio_cgroup.h & linux/module.h)
>>>
>>> Or maybe you want to remove linux/module.h inclusion from
>>> net/netprio_cgroup.h ???
>>
>> That would be the better solution. =A0I had them all killed off and =
it
>> would be nice to try and keep it that way as long as possible.
>>
>> I'll look into this if that wasn't part of Jesper's original intenti=
on.
>
> Jesper did you actually hit this problem and get a real build
> failure?

I've reproduced it locally, and verified it as a fix, but only *after*
I've deleted the module.h from netprio_cgroup.h

Doing builds to see what else (aside from the dsa/mv88e6xxx)
shakes loose.  Hopefully that is it.  If so, I'll send a patch
shortly to delete the module.h

Paul.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
