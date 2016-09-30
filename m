From: =?utf-8?Q?Toke_H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>
Subject: Re: [PATCH 3/3] mac80211: Set lower memory limit for non-VHT devices
Date: Fri, 30 Sep 2016 14:41:42 +0200
Message-ID: <87twcx5zll.fsf@toke.dk>
References: <20160923195911.4572-1-toke@toke.dk>
        <20160923195911.4572-4-toke@toke.dk>
        <1475235230.17481.43.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: make-wifi-fast@lists.bufferbloat.net,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.tohojo.dk ([77.235.48.147]:39206 "EHLO mail2.tohojo.dk"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932707AbcI3Mlw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 08:41:52 -0400
In-Reply-To: <1475235230.17481.43.camel@sipsolutions.net> (Johannes Berg's
        message of "Fri, 30 Sep 2016 13:33:50 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> On Fri, 2016-09-23 at 21:59 +0200, Toke H=C3=B8iland-J=C3=B8rgensen wrote:
>> Small devices can run out of memory from queueing too many packets.
>> If VHT is not supported by the PHY, having more than 4 MBytes of
>> total queue in the TXQ intermediate queues is not needed, and so we
>> can safely limit the memory usage in these cases and avoid OOM.
>
> I kinda see the logic here - we really don't need to queue as much if
> we can't possibly transmit it out quickly - but it seems to me we
> should also throw in some kind of limit that's relative to the amount
> of memory you have on the system?

Yes, ideally. That goes for FQ-CoDel as well, BTW. LEDE currently
carries a patch for that which just changes the hard-coded default to
another hard-coded default. Not sure how to get a good value to use,
though; and deciding on how large a fraction of memory to use for
packets starts smelling an awful lot like setting policy in the kernel,
doesn't it?

> I've applied these anyway though. I just don't like your assumption (b)
> much as the rationale for it.

Right, thanks. I'll come up with a better rationale next time ;)

-Toke
