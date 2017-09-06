From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 6 Sep 2017 18:42:17 +0200
Message-ID: <20170906164217.GE15315@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
 <20170906004703.GB27385@lunn.ch>
 <CAJieiUj-ObfKAZa18JxnWSswLGK-mRLjqE7qyCrZ5tsVftf46w@mail.gmail.com>
 <9ECEF4E4-A39B-4578-8BDC-7842D20F3C81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Woojung.Huh@microchip.com, jbe@pengutronix.de,
        sean.wang@mediatek.com, john@phrozen.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58870 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754272AbdIFQmW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 12:42:22 -0400
Content-Disposition: inline
In-Reply-To: <9ECEF4E4-A39B-4578-8BDC-7842D20F3C81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >On the switch asics we work with, the driver has information if the
> >packet was
> >forwarded in hardware. This is per packet reason code telling why the
> >CPU is seeing the packet.
> >The driver can use this information to reset skb->offload_fwd_mark to
> >allow software forward.

> I am not positive this is universally available across different
> switch vendors.

It is not universally available. We cannot rely on it being available
with switches supported by DSA.

We have a few choices:

1) We assume anything the switch forwards to the CPU has also been
   sent out whatever ports of the switch it needs to. Set
   offload_fwd_mark.

2) We assume anything the switch forwards to the CPU has not gone
   anywhere else, and the bridge needs to send it out whatever ports
   it thinks. Don't set offload_fwd_mark.

3) We define some rules about what packets the switch should handle,
   and then do some deep packet inspection to decide if
   offload_fwd_mark should be set or not.

I don't see 3) being possible. We are dealing with a fixed silicon
data path, not something which is fully programmable.

So it is down to 1) or 2). I've been assuming 1), but maybe we need to
discuss that as well.

	Andrew
