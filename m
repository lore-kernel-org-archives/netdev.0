From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 2/2] be2net: drop non-tso frames longer than mtu
Date: Wed, 16 Oct 2013 06:54:40 -0700
Message-ID: <1381931680.2045.127.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381838188-9625-1-git-send-email-sathya.perla@emulex.com>
	 <1381838188-9625-2-git-send-email-sathya.perla@emulex.com>
	 <1381844840.2045.37.camel@edumazet-glaptop.roam.corp.google.com>
	 <CF9D1877D81D214CB0CA0669EFAE020C26A2A3A4@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sathya Perla <Sathya.Perla@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:53404 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934252Ab3JPNym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 09:54:42 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so845528pbc.21
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 06:54:41 -0700 (PDT)
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C26A2A3A4@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-16 at 12:08 +0000, Sathya Perla wrote:

> Won't the mss (gso_size) value for TCP pkts be derived from the mtu of the out-going interface?
> In that case when will gso_size + headers > mtu?


Not on forwarding :(

Let see we have two ethernet devices, with different mtu : 1500 and 1400

GRO could aggregate GRO packets with MSS=1460 (gso_size=1460), then
we hapilly send this GSO packet to the other device, and apparently we
have no check against the lower mtu.

In the best case GRO packet is lost, but in some other cases, the device
hangs...

> In any case, for TSO pkts, the HW just drops pkts when frames after segmentation
> are longer than 9018bytes (or in recent FW versions 9200b)
