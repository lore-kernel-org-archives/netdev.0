From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v5 0/7] gtp: misc improvements
Date: Mon, 13 Mar 2017 17:48:12 +0100
Message-ID: <20170313164812.GA31925@salvia>
References: <20170309164302.13550-1-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@gnumonks.org>,
        osmocom-net-gprs@lists.osmocom.org, netdev <netdev@vger.kernel.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33402 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753269AbdCMQsT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 12:48:19 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 6521D1AAAEE
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 17:48:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 57647DA817
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 17:48:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3DD5CDA817
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 17:48:13 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170309164302.13550-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 09, 2017 at 05:42:55PM +0100, Andreas Schultz wrote:
> Hi Pablo,
> 
> This is a resent of last series that missed the merge window. There
> are no changes compared to v4.
> 
> v4: Compared to v3 it contains mostly smallish naming and spelling fixes.
> It also drops the documentation patch, Harald did a better job with the
> documentation and the some things I described do not yet match the implementation.
> I'll readd the relevant parts with a follow up series.
> 
> This series lays the groundwork for removing the socket references from
> the GTP netdevice by removing duplicate code and simplifying the logic on
> some code paths.
> 
> It slighly changes the GTP genl API by making the socket parameters optional
> (though one of them is still required).
> 
> The removal of the socket references will break the 1:1 releation between
> GTP netdevice and GTP socket that prevents us to support multiple VRFs with
> overlapping IP addresse spaces attached to the same GTP-U entity (needed for
> multi APN support, coming a follow up series).
> 
> Pablo found a socket hold problem in v2. In order to solve that I had to
> switch the socket references from the struct socket to the internal
> struct sock. This should have no functionl impact, but we can now hang
> on to the reference without blocking user space from closing the GTP socket.

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

I personally don't like this podge hodge unsorted submissions, I don't
think they belong to the same series but you keep pushing with this
patchset in this same way, which is annoying.

In your follow up patchsets, please split them in smaller series that
are related.

I would like you take the time to develop the VRF idea that you want
to introduce, I just would like that we avoid bloating the GTP tunnel
with features that we can just achieve via composite of different
subsystems.

Thank you.
