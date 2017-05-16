From: Ihar Hrachyshka <ihrachys@redhat.com>
Subject: Re: [PATCH] arp: honour gratuitous ARP _replies_
Date: Tue, 16 May 2017 08:01:34 -0700
Message-ID: <CAKwN9=AtFWADVRFXJROGJxF9g_3O_t9sWTRP3T9G1amzdaGMdA@mail.gmail.com>
References: <20170515.140832.354922796595622860.davem@davemloft.net> <20170515211616.26077-1-ihrachys@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Ihar Hrachyshka <ihrachys@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:36130 "EHLO
        mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751030AbdEPPBz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 11:01:55 -0400
Received: by mail-yw0-f171.google.com with SMTP id b68so54243144ywe.3
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 08:01:55 -0700 (PDT)
In-Reply-To: <20170515211616.26077-1-ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 15, 2017 at 2:16 PM, Ihar Hrachyshka <ihrachys@redhat.com> wrote:
> When arp_accept is 1, gratuitous ARPs are supposed to override matching
> entries irrespective of whether they arrive during locktime. This was
> implemented in commit 56022a8fdd87 ("ipv4: arp: update neighbour address
> when a gratuitous arp is received and arp_accept is set")
>
> There is a glitch in the patch though. RFC 2002, section 4.6, "ARP,
> Proxy ARP, and Gratuitous ARP", defines gratuitous ARPs so that they can
> be either of Request or Reply type. Those Reply gratuitous ARPs can be
> triggered with standard tooling, for example, arping -A option does just
> that.
>
> This patch fixes the glitch, making both Request and Reply flavours of
> gratuitous ARPs to behave identically.
>
> As per RFC, if gratuitous ARPs are of Reply type, their Target Hardware
> Address field should also be set to the link-layer address to which this
> cache entry should be updated. The field is present in ARP over Ethernet
> but not in IEEE 1394. In this patch, I don't consider any broadcasted
> ARP replies as gratuitous if the field is not present, to conform the
> standard. It's not clear whether there is such a thing for IEEE 1394 as
> a gratuitous ARP reply; until it's cleared up, we will ignore such
> broadcasts. Note that they will still update existing ARP cache entries,
> assuming they arrive out of locktime time interval.
>
> Signed-off-by: Ihar Hrachyshka <ihrachys@redhat.com>

Please disregard this email, I forgot to update the patch version to
v2 and provide changelog. I posted (hopefully) correct version. Still
learning the process...

Ihar
