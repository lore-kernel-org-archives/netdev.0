From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [Patch RFC net-next] net: usb: r8152: Fix rx_bytes/tx_bytes to
 include FCS
Date: Thu, 18 May 2017 19:33:39 +0200
Message-ID: <20170518173339.GF707@lunn.ch>
References: <1495052615-14360-1-git-send-email-andrew@lunn.ch>
 <286d107e-2380-f8e9-3edf-c949707ea235@gmail.com>
 <20170518150925.GB707@lunn.ch>
 <20170518.112256.671702749693595449.davem@davemloft.net>
 <b020ca48-d19a-9281-ee8a-d29038ee2b96@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        hayeswang@realtek.com, mario_limonciello@dell.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35955 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753623AbdERRdp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 13:33:45 -0400
Content-Disposition: inline
In-Reply-To: <b020ca48-d19a-9281-ee8a-d29038ee2b96@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian

I agree we should define this, and we can add it to
Documentation/ABI/testing/sysfs-class-net-statistics

> - BQL cares about bytes sent on the wire, so that should not include
> pre/appended descriptors nor the FCS (nor the Ethernet preamble),
> tx_bytes should be equivalent to that

Can you point me at some documentation/code which shows this?

pre/appended descriptors i can understand, since it does not make it
to the wire. FCS does. Preamble and inter-frame gap also does make it
to the wire, and contributes to the overall load on the medium. But i
would expect BQL is tolerant to this. We are talking about an error of
about 0.26% for a full MTU frame if FCS is included when it should not
be.

If BQL really does care about not including the FCS, we probably have
a lot less to do. People should of audited their code when they added
support for BQL :-)

    Andrew
