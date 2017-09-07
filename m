From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Thu, 7 Sep 2017 02:47:53 +0200
Message-ID: <20170907004753.GB30089@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
 <20170906004703.GB27385@lunn.ch>
 <CAJieiUj-ObfKAZa18JxnWSswLGK-mRLjqE7qyCrZ5tsVftf46w@mail.gmail.com>
 <9ECEF4E4-A39B-4578-8BDC-7842D20F3C81@gmail.com>
 <20170906164217.GE15315@lunn.ch>
 <44233399-2cb9-35af-2b93-b0024aac8dc4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Woojung.Huh@microchip.com, jbe@pengutronix.de,
        sean.wang@mediatek.com, john@phrozen.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59151 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752856AbdIGAr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 20:47:56 -0400
Content-Disposition: inline
In-Reply-To: <44233399-2cb9-35af-2b93-b0024aac8dc4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> At the very least we should probably move the skb->offload_fwd_mark
> setting down into the individual taggers since they should be in a
> better position to set it or not based on the switch device they are
> driving, this should address, on a per-switch basis whether 2) or 3)
> applies to a given switch.

Yes, that could be done.

> That being said, I have a feeling that the Marvell switches behave a
> tiny bit differently than others in that they do not flood broadcast by
> default in a given L2 domain.

It seems like the switch can be configured to flood broadcast. Just at
the moment, it is not.

> On b53/bcm_sf2 there is the ability to disable the reception of
> broadcast frames on the management/CPU port, and while there is the
> ability to configure which ports should be flooded in case of
> unicast/multicast lookup failures, I don't see anything for Broadcast,
> so I am assuming this will get forwarded by default. Will test with your
> patch set later on time permitting.

Please let me know the results of the tests.

If Marvell is being different, it also means that all other switches
today are duplicating broadcasts. We should fix that. In fact, i think
we need to fix this first, before these patches for IGMP snooping on
br0 goes in.

    Andrew
