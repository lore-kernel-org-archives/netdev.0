From: Justin van Wijngaarden <justinvanwijngaarden@gmail.com>
Subject: kernel driver "drivers/net/ethernet/realtek/r8169.c" msleep question
Date: Sun, 23 Feb 2014 23:38:40 +0100
Message-ID: <20140223223840.GA29808@snape.qqa.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:63572 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbaBWW7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 17:59:43 -0500
Received: by mail-ea0-f179.google.com with SMTP id q10so2746006ead.10
        for <netdev@vger.kernel.org>; Sun, 23 Feb 2014 14:59:42 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am in the progress of doing some checkpatch.pl clean-ups and took the above
driver to work on.

On line 6926 there is an msleep(1) statement.

According to the linux documentation @ Documentation/timers/timers-howto.txt
the msleep is not functioning as it should.

see output from that documentation below.

// quote
Why not msleep for (1ms - 20ms)?
	Explained originally here:
	http://lkml.org/lkml/2007/8/3/250
	msleep(1~20) may not do what the caller intends, and
	will often sleep longer (~20 ms actual sleep for any
	value given in the 1~20ms range).  In many cases this
	is not the desired behavior.
// end quote

If you like I can take a re-write to usleep (1ms) or perhaps a 10/20 msleep.
I tested it both with my own hardware which works fine on both cases, but
ofcourse I don't have the hardware to test it for all use-cases.

Any preference?

Regards,

Justin van Wijngaarden
