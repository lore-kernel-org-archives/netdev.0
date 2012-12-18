From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from userspace
Date: Tue, 18 Dec 2012 10:31:41 +0100
Message-ID: <20121218093141.GA1533@minipsycho.orion>
References: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
 <20121216105451.GA1546@minipsycho.orion>
 <20121217224957.70775f99@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com, fbl@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:43686 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635Ab2LRJbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 04:31:46 -0500
Received: by mail-wi0-f172.google.com with SMTP id o1so2525449wic.17
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 01:31:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121217224957.70775f99@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 18, 2012 at 07:49:57AM CET, shemminger@vyatta.com wrote:
>On Sun, 16 Dec 2012 11:54:51 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> 
>> I see that the patchset is in state "Rejected" in patchwork.
>> Stephen convinced me for a moment that the problem can be handled by operstate.
>> As it turned out (in last 3-4 emails in thread) operstate use would not
>> be an option.
>> 
>> So how should I proceed? Should I repost the patchset? Anyone has any other
>> comments?
>> 
>> thanks.
>
>Don't take my comments so far as negative. Devices to need to be more controllable
>from userspace. But I have concerns about introducing a new way to change state causing
>more races.  For example, changing carrier state should cause netlink events to fire and
>these should post to routing daemons etc. Also, what happens if some confused developer
>mixes operstate and direct carrier control.

I do not think that the race you are describing is of any concern. The
same can happen now for any device. My patchset only adds a possibility
for "soft devices" to change the carrier as well.

Developer will not be likely confused. As the possibility of carrier
change from userspace will be limited to small set of devices, for other
devices the attempt will lead to -EOPNOTSUPP (in contrast with operstate
which is available for all devices).

I can add a comments/notes to code and operstates.txt stating the
purpose of this iface.

>
>The root cause of all this confusion is that their are three ways of expressing
>the same state, and they are controlled through different paths:
>  a. Old BSD style flag bit IFF_RUNNING
>  b. LINK_STATE bit in kernel (netif_carrier_ok)
>  c. RFC2863 operational state

I do not think so. Yes, for a) and c), these are strictly connected,
expressing the same thing. But b) is not the same. It's on lower level
than a) and c). What b) can be compared to is IFF_LOWER_UP.

>
>The operstate stuff is the most complete, but is the weakest in implementation:
>  a. kernel drivers check netif_carrier_ok when they should be using netif_dormant
>     (bridge is one example). But what will break if this changes?
I agree, that should be changed.

>  b. lower device state is not tracked correctly by tunnels and a few other layered devices
>  c. dormant from kernel space was never used by much.
>
>The good news is that the old BSD style IFF_RUNNING bit is the most commonly
>used bit by applications and it works correctly in either carrier or operstate mode.

That is indeed a good thing.
