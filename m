From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: fix GRO parameters
Date: Wed, 16 Jan 2013 08:50:38 -0800
Message-ID: <1358355038.19956.694.camel@edumazet-glaptop>
References: <50F50537.3030608@broadcom.com>
	 <1358260752.8744.5677.camel@edumazet-glaptop>
	 <50F56178.8000502@broadcom.com>
	 <20130115.150914.729025796621947521.davem@davemloft.net>
	 <1358312188.19956.1.camel@edumazet-glaptop>
	 <1358314662.19956.51.camel@edumazet-glaptop>
	 <50F65060.5000901@broadcom.com>
	 <1358350146.19956.658.camel@edumazet-glaptop>
	 <50F6BB70.8070409@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>, ariele@broadc_tym.com
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:59623 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757745Ab3APQum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 11:50:42 -0500
Received: by mail-da0-f48.google.com with SMTP id k18so654564dae.7
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 08:50:41 -0800 (PST)
In-Reply-To: <50F6BB70.8070409@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-16 at 16:38 +0200, Yuval Mintz wrote:

> I think we have a misunderstanding here - when LRO is on, our FW works in
> TPA_MODE_LRO (LRO/GRO FW are mutually exclusive). In that mode, the bnx2x
> driver will not try to 'fake' GRO packets in the same manner.

I think you didn't really understand the issue then.

Call the hardware assist Receive Offload "LRO" if you really want, even
if not using net/ipv4/inet_lro.c , but provide :

gso_segs and gso_type as well. (Its useful for various things, check
netif_skb_features() for another example)

Or else we need to parse the headers again to check IPv4/ v6 / TCP / UDP
later.

There is no downside providing gso_segs and gso_type, you have all
needed information as shown in the patch I cooked and tested.

Our goal is to remove CONFIG_INET_LRO, so all multi-segments packets
should have the same set of parameters (gso_size, gso_segs, gso_type)
