From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Network cooling device and how to control NIC speed on thermal
 condition
Date: Fri, 28 Apr 2017 13:56:30 +0200
Message-ID: <20170428115630.GG13231@lunn.ch>
References: <CAHKzcEMQPQzg6PYCSuv7Ufad+4AZ2gnqMgz3-VH5NTeb_pv4zQ@mail.gmail.com>
 <20170425144501.0cfe27a5@lxorguk.ukuu.org.uk>
 <CAHKzcEO-75r5Gmew9x1eprh9ACf_NQKCHQg9svOLM1OmVX0JgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <gnomes@lxorguk.ukuu.org.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Waldemar Rymarkiewicz <waldemar.rymarkiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44323 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752466AbdD1L4d (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 07:56:33 -0400
Content-Disposition: inline
In-Reply-To: <CAHKzcEO-75r5Gmew9x1eprh9ACf_NQKCHQg9svOLM1OmVX0JgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I collect SoC temp every a few secs. Meantime, I use ethtool -s ethX
> speed <speed> to manipulate link speed and to see how it impacts SoC
> temp. My 4 PHYs and switch are integrated into SoC and I always
> change link speed for all PHYs , no traffic on the link for this test.
> Starting with 1Gb/s and then scaling down to 100 Mb/s and then to
> 10Mb/s, I see significant  ~10 *C drop in temp while link is set to
> 10Mb/s.

Is that a realistic test? No traffic over the network? If you are
hitting your thermal limit, to me that means one of two things:

1) The device is under very heavy load, consuming a lot of power to do
   what it needs to to.

2) Your device is idle, no packets are flowing, but your thermal
   design is wrong, so that it cannot dissipate enough heat.

It seems to me, you are more interested in 1). But your quick test is
more about 2).

I would be more interested in do quick tests of switching 8Gbps,
4Gbps, 2Gbps, 1Gbps, 512Mbps, 256Bps, ... What effect does this have
on temperature?

> So, throttling link speed can really help to dissipate heat
> significantly when the platform is under threat.
> 
> Renegotiating link speed costs something I agree, it also impacts user
> experience, but such a thermal condition will not occur often I
> believe.

It is a heavy handed approach, and you have to be careful. There are
some devices which don't work properly, e.g. if you try to negotiate
1000 half duplex, you might find the link just breaks.

Doing this via packet filtering, dropping packets, gives you a much
finer grained control and is a lot less disruptive. But it assumes
handling packets is what it causing you heat problems, not the links
themselves.

	Andrew
