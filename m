From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] net: bridge: suppress broadcast when multicast flood is
 disabled
Date: Mon, 24 Apr 2017 22:52:55 +0300
Message-ID: <5266c6fd-54e9-01c7-2379-0b7f11a3cde3@cumulusnetworks.com>
References: <1493042944-4005-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        roopa <roopa@cumulusnetworks.com>
To: Mike Manning <mmanning@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38287 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S977196AbdDXTw6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 15:52:58 -0400
Received: by mail-wm0-f50.google.com with SMTP id r190so78104713wme.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 12:52:57 -0700 (PDT)
In-Reply-To: <1493042944-4005-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/04/17 17:09, Mike Manning wrote:
> Flood suppression for packets that are not unicast needs to be handled
> consistently by also not flooding broadcast packets. As broadcast is a
> special case of multicast, the same kernel parameter should be used to
> suppress flooding for both of these packet types.
> 
> Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---
>  net/bridge/br_forward.c | 17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)
> 

I do not agree that this is a bug fix, the behaviour was intentional and is close to how HW
handles this flag. It has been like that for a few releases and changing it may impact setups
that use the flag since up until now they've seen the broadcast but not multicast packets and
suddenly their broadcast will stop.

I think it would be better to introduce a third flag for bcast in net-next and use that to
filter it since that would give us the ability to program HW that can distinguish these
and have both options available, moreover it will not break any user setups relying on
the current flag behaviour and we have such setups.

Thanks,
 Nik
