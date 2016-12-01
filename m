From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: DSA vs envelope frames
Date: Thu, 1 Dec 2016 21:46:58 +0900
Message-ID: <344d53f8-1365-b478-ad81-44722932de91@lab.ntt.co.jp>
References: <1480444528-30054-1-git-send-email-nikita.yoush@cogentembedded.com>
 <AM4PR0401MB2260D022EC9B9E4C4333E621FF8C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <dab27a3d-821c-8d07-ad98-2bdd8c442bc5@cogentembedded.com>
 <f632a0e8-746b-2db5-09af-3a5f6fc78e13@lab.ntt.co.jp>
 <d8a6df03-d9bd-eca5-0b9f-73406efe6509@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        lorian Fainelli <f.fainelli@gmail.com>
To: Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Andy Duan <fugang.duan@nxp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Andrew Lunn <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d8a6df03-d9bd-eca5-0b9f-73406efe6509@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/11/30 23:58, Nikita Yushchenko wrote:
>>> (1) When DSA is in use, frames processed by FEC chip contain DSA tag and
>>> thus can be larger than hardcoded limit of 1522. This issue is not
>>> FEC-specific, any driver that hardcodes maximum frame size to 1522 (many
>>> do) will have this issue if used with DSA.
>>
>> BTW I'm trying to introduce envelope frames to solve this kind of problems.
>> http://marc.info/?t=147496691500005&r=1&w=2
>> http://marc.info/?t=147496691500003&r=1&w=2
>> http://marc.info/?t=147496691500002&r=1&w=2
>> http://marc.info/?t=147496691500004&r=1&w=2
>> http://marc.info/?t=147496691500001&r=1&w=2
>>
>> It needs jumbo frame support of NICs though.
> 
> Thanks for pointing to this.
> 
> Indeed frame with DSA tag conceptually is an envelope frame.
> 
> ndev->env_hdr_len introduced by your patches, actually is explicitly
> handled difference between (MTU + 18) and frame that HW should allow.
> If this is known, hardware can be configured to work with DSA. At least
> FEC hardware that can send and receive "slightly larger" frames after
> simple register configuration.
> 
> Furthermore, since DSA configuration is known statically (it comes from
> device tree), ndo_set_env_hdr_len method could be automatically called
> at init, making setup working by default if driver supports that. And if
> not, perhaps can automatically lower MTU.
> 
> Looks like a solution :)
> 
> What's current status of this work?

Thank you for taking a look.
I'm planning to post v2 soon.

> What is not really clear - what if several tagging protocols are used
> together. AFAIU, things may be more complex that simple appending of
> tags, e.g. EDSA tag can carry VLAN id inside.

If kernel is aware of VLAN configuration, add 4 bytes + DSA tag size.
(I'm not familiar with how dsa knows vlan configuration, but probably
through switchdev_port_obj_add()? If so, dsa should be able to take into
account additional vlan tag size.)

If vlan tag is opaque from kernel, e.g. forwarding vlan tagged frames
without configuring vlan_filtering in bridge, admin needs to set
env_hdr_len manually. This is why I'm proposing manual operation.

Regards,
Toshiaki Makita
