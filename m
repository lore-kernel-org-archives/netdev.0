From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 3/3] mac80211: Set lower memory limit for non-VHT devices
Date: Fri, 30 Sep 2016 13:33:50 +0200
Message-ID: <1475235230.17481.43.camel@sipsolutions.net>
References: <20160923195911.4572-1-toke@toke.dk>
         <20160923195911.4572-4-toke@toke.dk> (sfid-20160923_215935_754766_6EB4EDBF)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
        make-wifi-fast@lists.bufferbloat.net,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:42459 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932731AbcI3Ldz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 07:33:55 -0400
In-Reply-To: <20160923195911.4572-4-toke@toke.dk> (sfid-20160923_215935_754766_6EB4EDBF)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-23 at 21:59 +0200, Toke Høiland-Jørgensen wrote:
> Small devices can run out of memory from queueing too many packets.
> If VHT is not supported by the PHY, having more than 4 MBytes of
> total queue in the TXQ intermediate queues is not needed, and so we
> can safely limit the memory usage in these cases and avoid OOM.

I kinda see the logic here - we really don't need to queue as much if
we can't possibly transmit it out quickly - but it seems to me we
should also throw in some kind of limit that's relative to the amount
of memory you have on the system?

I've applied these anyway though. I just don't like your assumption (b)
much as the rationale for it.

johannes
