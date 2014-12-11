From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: tg3 broken in 3.18.0?
Date: Thu, 11 Dec 2014 14:45:48 -0200
Message-ID: <5489CA3C.10803@gmail.com>
References: <20141210230634.GA22884@teela.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Nils Holland <nholland@tisys.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:50492 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbaLKQpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 11:45:53 -0500
Received: by mail-qg0-f49.google.com with SMTP id a108so4030257qge.22
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 08:45:53 -0800 (PST)
In-Reply-To: <20141210230634.GA22884@teela.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-12-2014 21:06, Nils Holland wrote:
> Hi everyone,
>
> I just upgraded a machine from 3.17.3 to 3.18.0 and noticed that after
> the upgrade, the machine's network interface (which is a tg3) would no
> longer run correctly (or, for that matter, run at all). During the
> upgrade, I didn't change any kernel config options or any other parts
> of the system.

Same thing here! Thanks for reporting this, Nils.

> Since the machine is remote and I don't have direct access to it, it's
> kind of hard currently to give more details, but here's what I'm
> seeing in the logs:

I have access to mine, kudos to secondary NIC.

$ ethtool -i p1p1
driver: tg3
version: 3.137
firmware-version: 5722-v3.13
bus-info: 0000:02:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no

$ ethtool p1p1
Settings for p1p1:
         Supported ports: [ TP ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Half 1000baseT/Full
         Supported pause frame use: No
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Half 1000baseT/Full
         Advertised pause frame use: Symmetric
         Advertised auto-negotiation: Yes
         Speed: Unknown!
         Duplex: Unknown! (255)
         Port: Twisted Pair
         PHYAD: 1
         Transceiver: internal
         Auto-negotiation: on
         MDI-X: Unknown

$ sudo ip link set p1p1 up
RTNETLINK answers: No such device

> If I see things correctly, there were only two patches affecting tg3
> between 3.17(.3) and 3.18:
>
> 2c7c9ea429ba30fe506747b7da110e2212d8fefa
> a620a6bc1c94c22d6c312892be1e0ae171523125

I'm running net-next, 395eea6ccf2b253f81b4718ffbcae67d36fe2e69.
So my diffs would be:
$ git log v3.17..origin/master --oneline -- drivers/net/ethernet/broadcom/tg3.c
892311f ethtool: Support for configurable RSS hash function
60b7379 Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
a620a6b tg3: fix ring init when there are more TX than RX channels
3964835 tg3: use netdev_rss_key_fill() helper
2c7c9ea tg3: Add skb->xmit_more support

Reverting all these, issue continues.

If no one has a better shot, I'll try bissecting later.

   Marcelo
