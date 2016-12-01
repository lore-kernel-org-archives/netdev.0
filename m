From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: DSA vs envelope frames
Date: Wed, 30 Nov 2016 19:26:59 -0800
Message-ID: <b75a3232-bdda-6758-874f-829b3e4097e9@gmail.com>
References: <1480444528-30054-1-git-send-email-nikita.yoush@cogentembedded.com>
 <AM4PR0401MB2260D022EC9B9E4C4333E621FF8C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <dab27a3d-821c-8d07-ad98-2bdd8c442bc5@cogentembedded.com>
 <f632a0e8-746b-2db5-09af-3a5f6fc78e13@lab.ntt.co.jp>
 <d8a6df03-d9bd-eca5-0b9f-73406efe6509@cogentembedded.com>
 <20161130151028.GD21645@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
        Andy Duan <fugang.duan@nxp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36341 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756803AbcLAD2h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 22:28:37 -0500
In-Reply-To: <20161130151028.GD21645@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/30/2016 07:10 AM, Andrew Lunn wrote:
>> What is not really clear - what if several tagging protocols are used
>> together. AFAIU, things may be more complex that simple appending of
>> tags, e.g. EDSA tag can carry VLAN id inside.
> 
> Hi Nikita
> 
> At least for all current tagging protocols, the size of the tag is
> constant. And you cannot run different tagging protocols on the same
> master interface at the same time.

I am not sure if using envelope frames is entirely appropriate here,
because there are existing switch tagging protocols that:

- don't have a specific Ethernet type allocated (Broadcom tags, DSA)
- could be appended at the end of the frame instead of pre-pended

Alexander Duyck suggested a while ago that we may be able to use the
headers_ops to implement the DSA tag pop/push, as well as get an
appropriate MTU adjustment, can you see if that would work?

> 
> However, i think Florian tried something funky with the SF2 and B53
> driver. He has a b53 hanging off a sf2. So i think he used nested
> tagging protocols!

Well, this actually did not work, because the SF2 and B53 switches
essentially terminate switch tags when they ingress their switch ports,
so the tag inserted by B53 ingressing into the SF2 port does not get
sent all the way to the CPU hanging off the SF2... With the B53 hanging
off the SF2, we essentially have to disable Broadcom tags in the B53
device, because the tag and switches were never designed to be cascaded
in the first place (at least not these specific cores).
-- 
Florian
