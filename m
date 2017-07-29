From: Mason <slash.tmp@free.fr>
Subject: Re: [RFC PATCH v1] net: ethernet: nb8800: Reset HW block in ndo_open
Date: Sun, 30 Jul 2017 00:48:59 +0200
Message-ID: <93bf2921-ac46-a11b-bd5d-d256123cc86a@free.fr>
References: <823b1540-b528-bbd7-7f99-5dc39a08868a@sigmadesigns.com>
 <yw1xk22slemx.fsf@mansr.com>
 <c1bf54ee-8634-23a1-abda-55bc3fafe2a8@sigmadesigns.com>
 <yw1xfudgl7am.fsf@mansr.com> <446e3a95-80c3-0742-9cb1-69a8dfc9b1ae@free.fr>
 <yw1x7eyrlc3s.fsf@mansr.com> <f04a0cba-6c09-e9e4-f2d1-d8b2a7e276c9@free.fr>
 <yw1x379fla7r.fsf@mansr.com> <bfc5678a-0536-7964-0d45-8f6b104e2f1a@free.fr>
 <2b1e69ed-7c95-d99c-5efc-bd5b23767d1e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:32219 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752209AbdG2WtO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Jul 2017 18:49:14 -0400
In-Reply-To: <2b1e69ed-7c95-d99c-5efc-bd5b23767d1e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/07/2017 22:15, Florian Fainelli wrote:

> On 07/29/2017 05:44 AM, Mason wrote:
>
>> We tested 4 switches, and DHCP failed on 3 of them.
>> Disabling pause frames "fixed" that.
> 
> OK, so it is this problem that you reported about before?

The "Ethernet flow control / pause frames" issue
is separate from the "link down wedges RX" issue.

We discussed the former back in November 2016:

https://www.mail-archive.com/netdev@vger.kernel.org/msg137094.html
https://patchwork.ozlabs.org/patch/694577/

Wait a second... I see that you and Mans had the
following exchange:

https://www.mail-archive.com/netdev@vger.kernel.org/msg138175.html

Mans mentions disabling DMA to be able to change
the flow control bits. The current theory is that
it is disabling DMA in ndo_stop that wedges RX.

So maybe the two issues are related after all...

I hate all these hardware quirks. Why can't HW
engineers make stuff that "just works"...

> Pause frames are tricky in that receiving pause frames means you
> should backpressure your transmitter and sending pause frames happens
> when your receiver cannot keep up. It is somewhat conceivable that
> your HW implementation is bogus and that you can get the HW in a
> state where it gets permanently backpressured for instance? And then
> only a full re-init would get you out of this stuck state presumably?
> Are there significant differences at the DMA/Ethernet controller
> level between Tango 3 (is that the one Mans worked on?) and Tango 4
> for instance that could explain a behavioral difference?

I'll have to take a look at the issue in light of
the new information. FWIW, Mans has tango3&4 boards.
I work on newer boards. The HW dev *swears* there
have been no functional differences in the eth block
"forever". However, bus accesses are faster in recent
chips, which could change who wins specific races.

Regards.
