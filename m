From: Amir Vadai <amirv@dev.mellanox.co.il>
Subject: Re: RFS issue: no HW filter for paused stream
Date: Mon, 19 Sep 2011 09:05:08 +0300
Message-ID: <CAP7N4Kes9=VdRV8NHvk03SBg5GbohgdbGqKPABCfYbVyzZ+1ng@mail.gmail.com>
References: <CAP7N4Kfd9TOPr_V6+R9yVtK80eGWbkAvPE8BStG0+WhvJHaLGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: oren@mellanox.co.il, liranl@mellanox.co.il, netdev@vger.kernel.org,
	amirv@mellanox.co.il
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52745 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939Ab1ISGFJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 02:05:09 -0400
Received: by iaqq3 with SMTP id q3so4957988iaq.19
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2011 23:05:08 -0700 (PDT)
In-Reply-To: <CAP7N4Kfd9TOPr_V6+R9yVtK80eGWbkAvPE8BStG0+WhvJHaLGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Resending in plain text)

Tom Hi,
When a stream is paused, and its rule is expired while it is paused,
no new rule will be configured to the HW when traffic resume.

Scenario:
1. Start iperf.
2. Pause it using Ctrl-Z
3. Start another iperf (to make sure first stream rule is expired)
4. Stop the second stream.
5. Resume first stream. Traffic is not steered to the right rx-queue.

=46rom looking at the code:
- When first stream started, RSS steered traffic to rx-queue 'x'.
Because iperf server was running on a different CPU, a new rule was
added and current-cpu was set to desired-cpu.
- After paused, rule was expired and removed from HW by net driver.
But current-cpu wasn't cleared and still is equal to desired-cpu.
- When stream was resumed, traffic was steered again by RSS, and
because current-cpu was equal to desired-cpu, =A0ndo_rx_flow_steer
wasn't called and no rule was configured to the HW.

Why isn't current-cpu cleared when expiring a rule?
- Amir
