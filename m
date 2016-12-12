From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store
 multicast entries
Date: Mon, 12 Dec 2016 08:37:50 -0800
Message-ID: <48ff1136-dd8f-7704-a512-c23b27989bf8@gmail.com>
References: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com>
 <87r35db35m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CAMr9Lbp5eCg1oyWGN+uiDEcF0VZuKUi87FH6JYTGj6pL82R+Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>, andrew@lunn.ch,
        netdev@vger.kernel.org,
        Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
To: Volodymyr Bendiuga <valdr.linuxnext@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34540 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752831AbcLLQhw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 11:37:52 -0500
Received: by mail-pg0-f67.google.com with SMTP id e9so1446729pgc.1
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 08:37:52 -0800 (PST)
In-Reply-To: <CAMr9Lbp5eCg1oyWGN+uiDEcF0VZuKUi87FH6JYTGj6pL82R+Mw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2016 07:22 AM, Volodymyr Bendiuga wrote:
> Hi,
> 
> I apologise for incorrectly formatted patch, I will fix and resend it.
> The problem with the ATU right now is that it is too slow when inserting
> entries.
> When the OS boots up, it might insert some multicast entries into the
> atu (if
> they are preconfigured by user). I run a test with 10 mc entries being
> configured for
> each port (13 ports), and it took 15 seconds, which made system quite
> slow on responding to
> other commands, as it has been inserting mc entries. The implementation
> with hashtable
> made insert command for 13 ports and 10 entries per port about 700 msec
> long.


Just wondering how do you achieve such speed up? What part of using a
hashtable allows you not to write down all 10 MC entries across the
ports? I would assume that the number of MDIO (is that the bus you are
using here?) operations would be identical.

Seeing such a change makes me wonder if we should not try to push some
of this hashtable abstraction (provided that we agree we want it) at a
higher layer, like net/dsa/slave.c?

Thanks!
-- 
Florian
