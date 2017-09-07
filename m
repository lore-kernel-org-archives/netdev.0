From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: VLAN/bridge "compression" in wifi (was: Re: [PATCH 3/8]
 qtnfmac: implement AP_VLAN iftype support)
Date: Thu, 07 Sep 2017 08:45:20 +0200
Message-ID: <1504766720.23905.25.camel@sipsolutions.net>
References: <20170620195517.18373-1-sergey.matyukevich.os@quantenna.com>
         <20170620195517.18373-4-sergey.matyukevich.os@quantenna.com>
         <1504619151.12380.16.camel@sipsolutions.net>
         <1504621233.12380.21.camel@sipsolutions.net>
         <20170906154522.twtesbo2rxbrhekf@bars>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        Igor Mitsyanko <igor.mitsyanko.os@quantenna.com>,
        Avinash Patil <avinashp@quantenna.com>
To: Sergey Matyukevich <sergey.matyukevich.os@quantenna.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40314 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753062AbdIGGpW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 02:45:22 -0400
In-Reply-To: <20170906154522.twtesbo2rxbrhekf@bars>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> > To clarify, I think what you - conceptually - want is the following
> > topology:
> > 
> >         +--- eth0.1  ---  br.1  ---  wlan0.1
> >         |
> > eth0 ---+--- eth0.2  ---  br.2  ---  wlan0.2
> >         |
> >         +--- eth0.3  ---  br.3  ---  wlan0.3
[...]
> That's right. In fact, hostapd is able to create this kind of network
> bridge infrastructure automatically when it is built
> with CONFIG_FULL_DYNAMIC_VLAN option enabled.

Cool, I was unaware of the exact functionality of this build-time
option. :)

> > Now, you seem to want to compress this to
> > 
> >                   +---  wlan0.1
> >                   |
> > eth0  ---  br  ---+---  wlan0.2
> >                   |
> >                   +---  wlan0.3

[...]

> Exactly. And yes, the only purpose of this 'non-conventional' mode
> was to have 802.1Q acceleration on the ethernet port.

Right. You can still have acceleration in the top picture by placing
the feature into the Ethernet hardware, so that tagging/untagging
doesn't have to touch the packet data but just touches (skb) metadata.
But obviously that's something that happens on the other side and you
don't have control over it.

Anyway, I'm happy we cleared up what was going on and also that you
decided to leave it for now and work with the regular Linux topology
model.

Thanks,
johannes
