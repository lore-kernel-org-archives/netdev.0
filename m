From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Thu, 7 Sep 2017 02:43:08 +0200
Message-ID: <20170907004308.GA30089@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
 <20170906004703.GB27385@lunn.ch>
 <CAJieiUj-ObfKAZa18JxnWSswLGK-mRLjqE7qyCrZ5tsVftf46w@mail.gmail.com>
 <9ECEF4E4-A39B-4578-8BDC-7842D20F3C81@gmail.com>
 <20170906164217.GE15315@lunn.ch>
 <44233399-2cb9-35af-2b93-b0024aac8dc4@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40B19584@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
        jbe@pengutronix.de, sean.wang@mediatek.com, john@phrozen.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59142 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751369AbdIGAnN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 20:43:13 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40B19584@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 06, 2017 at 11:44:47PM +0000, Woojung.Huh@microchip.com wrote:
> > That being said, I have a feeling that the Marvell switches behave a
> > tiny bit differently than others in that they do not flood broadcast by
> > default in a given L2 domain.
> Florian,
> 
> Because some DSA switches from Marvell & Microchip can do IGMP snooping, 
> can we propose switch layer another flag what to do when HW support it?
 
Hi Woojung

I expect all the current DSA devices should be able to do IGMP
snooping, with some modifications.

Two things are required:

1) The .port_mdb_prepare, .port_mdb_add and .port_mdb_del ops, so that
mdb entries can be added. As you said, only Marvell and Microchip
support these, but i expect the other switch can do this, it just
needs implementing.

2) The switch needs to identify and forward IGMP packets to the host,
even when they would normally be blocked.

And for the implementation, i don't think it actually matters.  For
switches which don't implement the port_mdb operations, IGMP packets
will get forwarded to the software bridge. It will attempt to put in
an mdb, but the request will come back with EOPNOTSUPP. The switch
should continue to flood multicast out all ports. No harm done.

       Andrew
