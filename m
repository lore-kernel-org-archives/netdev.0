From: Mason <slash.tmp@free.fr>
Subject: Re: [RFC PATCH v1] net: ethernet: nb8800: Reset HW block in ndo_open
Date: Sat, 29 Jul 2017 14:02:00 +0200
Message-ID: <f04a0cba-6c09-e9e4-f2d1-d8b2a7e276c9@free.fr>
References: <823b1540-b528-bbd7-7f99-5dc39a08868a@sigmadesigns.com>
 <yw1xk22slemx.fsf@mansr.com>
 <c1bf54ee-8634-23a1-abda-55bc3fafe2a8@sigmadesigns.com>
 <yw1xfudgl7am.fsf@mansr.com> <446e3a95-80c3-0742-9cb1-69a8dfc9b1ae@free.fr>
 <yw1x7eyrlc3s.fsf@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:27935 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753166AbdG2MCH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Jul 2017 08:02:07 -0400
In-Reply-To: <yw1x7eyrlc3s.fsf@mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/07/2017 13:24, Måns Rullgård wrote:

> Until you figure out why it's getting stuck, we can't be sure
> it isn't caused by something that could trigger at any time.
Would you take a look at it, if I can reproduce on tango4?

I have identified a 100% reproducible flaw.
I have proposed a work-around that brings this down to 0
(tested 1000 cycles of link up / ping / link down).

In my opinion, upstream should consider this work-around
for inclusion. I'd like to hear David's and Florian's
opinion on the topic. It's always a pain to maintain
out-of-tree patches.

> Yes, but by then you've reset those parameters to the defaults.

Good catch. There is some non HW-related init in
nb8800_hw_init().

I'll take this opportunity to change flow control to
off by default (it breaks several 100 Mbps switches).
I'll take a closer look at priv assignments on Monday.

Regards.
