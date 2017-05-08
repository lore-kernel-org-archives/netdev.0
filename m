From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: FEC on i.MX 7 transmit queue timeout
Date: Mon, 8 May 2017 02:13:25 +0000
Message-ID: <AM4PR0401MB2260D9D293EE8A37B93554F6FFEE0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <86b63ee28acfff3426c4a0bf72d848c1@agner.ch>
 <2bdd64ab-5644-e0a0-9bfe-b8dd2fca7abb@nxp.com>
 <80191e7c9df5871cd450f13b9ea47a10@agner.ch>
 <ab1fc814-4a81-9eb0-b20b-2cd325158ba8@nxp.com>
 <e366479239b66ba80415b5594def2369@agner.ch>
 <AM4PR0401MB2260F011313883C522EA7684FFEA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <e044b850a90e7112028cc12977d15cf2@agner.ch>
 <e739d361-c20f-0de1-cdd1-c9aa13a0d11a@nxp.com>
 <110a7a48649cfcbbee46340c230e9008@agner.ch>
 <46a27329-36df-1eaf-1321-24db037842fe@nxp.com>
 <20170505122330.GA23432@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Stefan Agner <stefan@agner.ch>,
        "festevam@gmail.com" <festevam@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0087.outbound.protection.outlook.com ([104.47.2.87]:48800
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750943AbdEHCN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 7 May 2017 22:13:29 -0400
In-Reply-To: <20170505122330.GA23432@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch> Sent: Friday, May 05, 2017 8:24 PM
>To: Andy Duan <fugang.duan@nxp.com>
>Cc: Stefan Agner <stefan@agner.ch>; festevam@gmail.com;
>netdev@vger.kernel.org; netdev-owner@vger.kernel.org
>Subject: Re: FEC on i.MX 7 transmit queue timeout
>
>> No, it is not workaround. As i said, quque1 and queue2 are for AVB
>> paths have higher priority in transmition.
>
>Does this higher priority result in the low priority queue being starved? =
Is that
>why the timer goes off? What happens when somebody does use AVB. Are
>we back to the same problem? This is what seems to make is sounds like a
>work around, not a fix.
>
>     Andrew
Yes, queue0 may be blocked by queue1 and queue2, then the queue0 watchdog t=
ime maybe triggered.
If somebody use AVB quque1 and queue2, the remaining bandwidth is for queue=
0, for example, in 100Mbps system, quque1 cost 50Mbps bandwidth and queue2 =
cost 50Mbps bandwidth for audio and video streaming, then queue0 (best effo=
rt) has 0 bandwidth that limit user case cannot have  asynchronous frames (=
IP(tcp/udp)) on networking. Of course these is extreme case.=20
In essentially,  asynchronous frames (IP) go queue0 for the original design=
. To do these just implement .ndo_select_queue() callback in driver like fs=
l tree.

Regards,
Andy
