From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH stable 3.11+] can: use private sk reference to detect
 originating socket
Date: Wed, 29 Jan 2014 08:12:53 -0800
Message-ID: <1391011973.28432.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52E905C8.1060408@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch2@gmail.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:51811 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbaA2QMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 11:12:55 -0500
Received: by mail-pd0-f170.google.com with SMTP id p10so1881292pdj.1
        for <netdev@vger.kernel.org>; Wed, 29 Jan 2014 08:12:54 -0800 (PST)
In-Reply-To: <52E905C8.1060408@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-29 at 14:44 +0100, Oliver Hartkopp wrote:

> ps. I would suggest to move the BUG() in WARN_ON_ONCE() to fulfill the
> requirement to detect a possible misuse but not kill the entire machine.
> BUG() is intended to be used when there's no way to continue any reasonable
> operation. Detecting and fixing this issue half a year after the "temporary
> sanity check" has been integrated is a bad example for using BUG() IMO.

I find worrying it took 6 months for CAN developers to hit this problem.

A WARN_ON_ONCE() has almost no chance being noticed in the embedded
world, and makes no pressure on developers to fix the bugs.

Patch is 6 months old, and will be reverted when we have confidence that
all offenders are fixed. Your feedback shows that we shall wait 10 years
just to make sure, and maybe we wont revert it.

All BUG() in the kernel have the property to potentially halt a
perfectly working machine, at a bad time, yes. But they make us
build a better kernel.
