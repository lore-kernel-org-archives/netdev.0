From: Andy Lutomirski <luto@amacapital.net>
Subject: sfc MC errors when using accelerated RFS
Date: Thu, 19 May 2016 09:01:53 -0700
Message-ID: <CALCETrXHQr5K_ttGaF2N5Og0vcDcpsM-2uu8h6mRbgryBfAyHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Network Development <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Shradha Shah <sshah@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:33029 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760AbcESQCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 12:02:14 -0400
Received: by mail-oi0-f53.google.com with SMTP id v145so135775415oie.0
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 09:02:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After a couple weeks of uptime under moderate accelerated RFS load
(mostly long-lived flows), I start getting errors like this:

sfc 0000:05:00.1 p3p2: MC command 0x8a inlen 108 failed rc=-28 (raw=28) arg=2

I've seem problems like this for a long time, and they're currently
happening on a stock 4.5.2 kernel using the in-tree sfc driver.  My
best guess is that something's wrong with the RFS state machine or
flow tracking and that the core or the driver's idea of the loaded
filters gets out of sync with the NIC.

If this isn't fixed, at some point we'll give up on Solarflare devices
and switch to something else.

I think that SolarFlare is internally tracking this as issue 42806.

--Andy
