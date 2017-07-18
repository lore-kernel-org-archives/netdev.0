From: Simon McVittie <simon.mcvittie@collabora.co.uk>
Subject: Re: [PATCH] net/unix: drop obsolete fd-recursion limits
Date: Tue, 18 Jul 2017 10:56:24 +0100
Message-ID: <20170718095605.753goswz5ildy3de@archetype.pseudorandom.co.uk>
References: <20170717093554.16459-1-dh.herrmann@gmail.com>
 <20170717.085821.179430433629233314.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dh.herrmann@gmail.com, netdev@vger.kernel.org, teg@jklm.no,
        eric.dumazet@gmail.com, hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:36436 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751371AbdGRJ42 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 05:56:28 -0400
Content-Disposition: inline
In-Reply-To: <20170717.085821.179430433629233314.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Jul 2017 at 08:58:21 -0700, David Miller wrote:
> > With all of this in mind, lets drop the recursion limit. It has no
> > additional security value, anymore. On the contrary, it randomly
> > confuses message brokers that try to forward file-descriptors, since
> > any sendmsg(2) call can fail spuriously with ETOOMANYREFS if a client
> > maliciously modifies the FD while inflight.
> 
> Applied, thanks.

I assume I was cc'd on this as a maintainer of one of the message
brokers that handles ETOOMANYREFS (dbus-daemon).

dbus-daemon will have to keep its current handling of ETOOMANYREFS
(namely dropping the message on the floor) for at least a few years,
to avoid re-introducing local denial of service CVE-2014-3532 on kernels
older than the one where you applied this; so please try to avoid reusing
ETOOMANYREFS for any new sendmsg() error condition where this would not
be an appropriate response.

Thanks,
    S
