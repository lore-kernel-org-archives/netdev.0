From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: Large performance regression with 6in4 tunnel (sit)
Date: Tue, 29 Nov 2016 09:38:09 +1100
Message-ID: <20161129093809.45bae6d1@canb.auug.org.au>
References: <20161125120947.142c3af5@canb.auug.org.au>
        <cf2fff0a-7d41-1416-0056-3718ea50a5bd@gmx.com>
        <20161125134520.68ca0969@canb.auug.org.au>
        <alpine.DEB.2.20.1611250503250.22094@aurora.sdinet.de>
        <20161127142340.3a5c197e@canb.auug.org.au>
        <CAKgT0Ue3f0hUnCvwBupqmhBE_bbxZUO7ODXsz2cbHrPu5gAqyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sven-Haegar Koch <haegar@sdinet.de>,
        Eli Cooper <elicooper@gmx.com>,
        Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:51113 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755608AbcK1WiW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 17:38:22 -0500
In-Reply-To: <CAKgT0Ue3f0hUnCvwBupqmhBE_bbxZUO7ODXsz2cbHrPu5gAqyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

On Mon, 28 Nov 2016 13:32:21 -0800 Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
> So I think I have this root caused.  The problem seems to be the fact
> that I chose to use lco_csum when trying to cancel out the inner IP
> header from the checksum and it turns out that the transport offset is
> never updated in the case of these tunnels.
> 
> For now a workaround is to just set tx-gso-partial to off on the
> interface the tunnel is running over and you should be able to pass
> traffic without any issues.

OK, so that works (even with gso and tso set to "on" on the sit
interface).  Thanks.

> I have a patch for igb/igbvf that should be out in the next hour or so
> which should address it.

That will be a bit harder to test, but I will see what I can do.

-- 
Cheers,
Stephen Rothwell
