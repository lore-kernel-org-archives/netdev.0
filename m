From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Wed, 2 Aug 2017 14:51:44 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00491F6@AcuExch.aculab.com>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-2-git-send-email-timur@codeaurora.org>
 <063D6719AE5E284EB5DD2968C1650D6DD00490C0@AcuExch.aculab.com>
 <77de100a-42b1-1e0d-6545-cadb0067eec6@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Timur Tabi' <timur@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:61116 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752185AbdHBOvw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 10:51:52 -0400
In-Reply-To: <77de100a-42b1-1e0d-6545-cadb0067eec6@codeaurora.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi
> Sent: 02 August 2017 15:22
> On 8/2/17 8:48 AM, David Laight wrote:
> > If the nearby switches cannot handle pause frames, then the MAC shouldn't
> > be sending them at all.
> 
> There's no way for me to know whether the switches can handle the pause
> frames or not.  You would think that sending one multicast pause frame
> ever 33ms would not overload a switch, but in our lab it does.
> 
> This is why I changed the default to disable sending pause frames.
...

Thinks ...
Sending pause frames just tells the adjacent switch not to send you packets
(because you'll discard them).
Since the idea is to avoid the discards, the switch will buffer the
packets it would have sent.
The buffers in the switch then fill up with packets it isn't sending you.
The switch then runs out of buffers, it has 2 choices:
1) Throw the packets away.
2) Send 'pause' frames to the sources.
If it sends 'pause' frames the entire network will very quickly lock up.
If it discards the packets they might as well have been discarded by the
receiving MAC.

Doesn't this mean that pause frames are 99.999% useless??

	David
