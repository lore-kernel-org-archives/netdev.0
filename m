From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [patch net / RFC] net: fec: increase frame size limitation to
 actually available buffer
Date: Wed, 30 Nov 2016 16:25:30 +0900
Message-ID: <f632a0e8-746b-2db5-09af-3a5f6fc78e13@lab.ntt.co.jp>
References: <1480444528-30054-1-git-send-email-nikita.yoush@cogentembedded.com>
 <AM4PR0401MB2260D022EC9B9E4C4333E621FF8C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <dab27a3d-821c-8d07-ad98-2bdd8c442bc5@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Andy Duan <fugang.duan@nxp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Andrew Lunn <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:54440 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751566AbcK3H1I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 02:27:08 -0500
In-Reply-To: <dab27a3d-821c-8d07-ad98-2bdd8c442bc5@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/11/30 15:36, Nikita Yushchenko wrote:
>> But I think it is not necessary since the driver don't support jumbo frame.
> 
> Hardcoded 1522 raises two separate issues.
> 
> (1) When DSA is in use, frames processed by FEC chip contain DSA tag and
> thus can be larger than hardcoded limit of 1522. This issue is not
> FEC-specific, any driver that hardcodes maximum frame size to 1522 (many
> do) will have this issue if used with DSA.
> 
> Clean solution for this must take into account that difference between
> MTU and max frame size is no longer known at compile time. Actually this
> is the case even without DSA, due to VLANs: max frame size is (MTU + 18)
> without VLANs, but (MTU + 22) with VLANs. However currently drivers tend
> to ignore this and hardcode 22.  With DSA, 22 is not enough, need to add
> switch-specific tag size to that.
> 
> Not yet sure how to handle this. DSA-specific API to find out tag size
> could be added, but generic solution should handle all cases of dynamic
> difference between MTU and max frame size, not only DSA.

BTW I'm trying to introduce envelope frames to solve this kind of problems.
http://marc.info/?t=147496691500005&r=1&w=2
http://marc.info/?t=147496691500003&r=1&w=2
http://marc.info/?t=147496691500002&r=1&w=2
http://marc.info/?t=147496691500004&r=1&w=2
http://marc.info/?t=147496691500001&r=1&w=2

It needs jumbo frame support of NICs though.

Regards,
Toshiaki Makita
