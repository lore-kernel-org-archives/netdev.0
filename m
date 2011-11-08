From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 6/6] [6LoWPAN] update documentation
Date: Tue, 8 Nov 2011 18:32:28 +0400
Message-ID: <CALT56yOb5oZLEuHcM8dM8_gpT7mzV+9_YbsxWL3nU2N3ypCg3w@mail.gmail.com>
References: <20111102162520.GA2669@avtobot.cybertron>
	<1320251754-2971-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:48423 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754854Ab1KHOcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 09:32:32 -0500
Received: by pzk2 with SMTP id 2so1597150pzk.1
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 06:32:32 -0800 (PST)
In-Reply-To: <1320251754-2971-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/2/11, Alexander Smirnov <alex.bluesman.smirnov@gmail.com> wrote:
> This patch adds chapter to documentation which describes how to use
> 6lowpan technology.
>
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> ---
>  Documentation/networking/ieee802154.txt |   26 ++++++++++++++++++++++++++
>  1 files changed, 26 insertions(+), 0 deletions(-)
>
> diff --git a/Documentation/networking/ieee802154.txt
> b/Documentation/networking/ieee802154.txt
> index 23c995e..7d50b26 100644
> --- a/Documentation/networking/ieee802154.txt
> +++ b/Documentation/networking/ieee802154.txt
> @@ -78,3 +78,29 @@ in software. This is currently WIP.
>
>  See header include/net/mac802154.h and several drivers in
> drivers/ieee802154/.
>
> +6LoWPAN Linux implementation
> +============================
> +
> +The IEEE 802.15.4 standard specifies an MTU of 128 bytes, yielding about 80
> +octets of actual MAC payload once security is turned on, on a wireless link
> +with a link throughput of 250 kbps or less.  The 6LoWPAN adaptation format
> +[RFC4944] was specified to carry IPv6 datagrams over such constrained
> links,
> +taking into account limited bandwidth, memory, or energy resources that are
> +expected in applications such as wireless Sensor Networks.  [RFC4944]
> defines
> +a Mesh Addressing header to support sub-IP forwarding, a Fragmentation
> header
> +to support the IPv6 minimum MTU requirement [RFC2460], and stateless header
> +compression for IPv6 datagrams (LOWPAN_HC1 and LOWPAN_HC2) to reduce the
> +relatively large IPv6 and UDP headers down to (in the best case) several
> bytes.

It might be a good idea to mention fresh RFC 6282, to note that it
updates RFC 4944,
deprecating old compression schemes and adding a new one. Then you can
add a note
that following RFC 6282 6lowpan code doesn't implement compression via
HC1 and HC2
schemes (it doesn't, am I right?).

> +
> +All the code related to 6lowpan you may find in files:
> net/ieee802154/6lowpan.*
> +
> +To setup 6lowpan interface you need:
> +1. Add IEEE802.15.4 interface and initialize PANid;
> +2. Add 6lowpan interface by command like:
> +   # ip link add link wpan0 name lowpan0 type lowpan

Does this work with busybox ip or only with iproute2?

> +3. Set MAC (if needs):
> +   # ip link set lowpan0 address de:ad:be:ef:ca:fe:ba:be

IIRC address can be also specified at the step 2.

> +4. Bring up 'lowpan0' interface

-- 
With best wishes
Dmitry
