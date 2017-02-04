From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/6] net: dsa: introduce bridge notifier
Date: Sat, 4 Feb 2017 18:55:17 +0100
Message-ID: <20170204175517.GC8364@lunn.ch>
References: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
 <20170203182021.14246-7-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, cphealy@gmail.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55670 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751467AbdBDRzW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 4 Feb 2017 12:55:22 -0500
Content-Disposition: inline
In-Reply-To: <20170203182021.14246-7-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +#define DSA_NOTIFIER_BRIDGE_JOIN		1
> +#define DSA_NOTIFIER_BRIDGE_LEAVE		2

Hi Vivien

Is one notifier per event sufficient?

I've not looked at what actually needs to happen when a port joins a
bridge, in a D in DSA setup. Do we need to both enable the flow of
frames around the switch fabric, but also block those frames going out
ports they should not? Do we need a first notifier to put in place
the blocks, and then a second notifier to enable the flow of packets?

What we don't want is a window of time during the fabric setup as a
whole is inconsistent, and frames a leaking out ports they should not.

      Andrew
