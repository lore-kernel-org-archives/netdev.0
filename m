From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next v2] net: bcmgenet: collect Rx discarded packet count
Date: Wed, 11 Mar 2015 10:59:32 -0700
Message-ID: <CAGXr9JHSGtySCs80PfSPBGbWyTXiE3pA0esi=fyCMPKRxmhboA@mail.gmail.com>
References: <20150310225500.8FA34220365@puck.mtv.corp.google.com>
	<CAGVrzcYNMsCKGdouLULKBb6dtMYviAJR26vO4XTJrh3aYSZC4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:35019 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274AbbCKR7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:59:33 -0400
Received: by qcwr17 with SMTP id r17so12345578qcw.2
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 10:59:32 -0700 (PDT)
In-Reply-To: <CAGVrzcYNMsCKGdouLULKBb6dtMYviAJR26vO4XTJrh3aYSZC4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find the Rx discard counter very useful, as it indicates HW dropped
packets, which directly affects media playback quality.

In our unit tests, we actually discovered a major interrupts-off
offender with this. Even with a moderate Rx traffic, we were seeing Rx
discards. It turned out that using a large dmesg log buffer and
dumping it with "cat /proc/kmsg" held interrupts off for long enough
that bcmgenet experienced discards. It was very useful to have the
discard data available when debugging this.
