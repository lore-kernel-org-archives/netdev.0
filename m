From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: QUESTION: How to fix race between .suspend routine and watchdog timer
Date: Thu, 25 Oct 2007 06:12:44 +0200
Message-ID: <200710250612.44296.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-pm@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:9798 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100AbXJYENb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 00:13:31 -0400
Received: by ug-out-1314.google.com with SMTP id z38so440619ugc
        for <netdev@vger.kernel.org>; Wed, 24 Oct 2007 21:13:29 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Recently, trying to fix saa7134 suspend/resume problems I found that there 
is a race between IRQ handler and .suspend , and that I cant let driver access the device
while its in D3 since it can lock up some systems.

Now I am looking to fix those issues in two drivers that have my .suspend/.resume routines.
the saa7134 capture chip and dmfe, the davicom network driver.

Looking through the dmfe code, I noticed yet another possible race.
A race between the .suspend, and a timer that serves both as a watchdog, and link state detector.
Again I need to prevent it from running during the suspend/resume, but how?

I can use del_timer in .suspend, and mod_timer in .resume, but that doesn't protect against
race with already running timer.
I can use del_timer_sync, but it states that it is useless if timer re-enables itself, and I agree with that.
In dmfe case the timer does re-enable itself.

I can put checks in the timer for ->insuspend, and don't re enable it if set,
but that opens a new can of worms with memory barriers, etc...

So please tell me how properly to do that.

By the way, this problem, together with synchronize_irq it very generic, since most drivers
have and irq handler, and a timeout timer.

Best regards,
	Maxim Levitsky
