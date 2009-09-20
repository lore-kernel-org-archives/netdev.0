From: Robert Hancock <hancockrwd@gmail.com>
Subject: r8169 64-bit DMA support
Date: Sun, 20 Sep 2009 17:38:20 -0600
Message-ID: <4AB6BCEC.3070001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f199.google.com ([209.85.210.199]:37036 "EHLO
	mail-yx0-f199.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbZITXiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2009 19:38:20 -0400
Received: by yxe37 with SMTP id 37so2568582yxe.33
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2009 16:38:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The r8169 driver currently disables 64-bit DMA support by default (needs 
a module parameter to turn it on). This is a bit sub-optimal these days 
with most new systems using more than 4GB of RAM. It was this patch back 
in 2004 that disabled it:

http://git.kernel.org/?p=linux/kernel/git/torvalds/old-2.6-bkcvs.git;a=commitdiff;h=c525e7cf69bfe18a1bf362558be5398e0b925d07

It's not clear (from the mails I've read) exactly what was going on in 
the case that caused this to be added. Normally these days the PCI 
subsystem is supposed to detect that DAC isn't usable on a machine and 
refuse setting 64-bit DMA masks, it's not the driver's responsibility to 
handle this. I'm guessing that when this change was made that detection 
didn't exist though.

Thoughts on whether this default can be changed now? Or at least for the 
PCI Express devices, which really should have nothing special about 
64-bit addressing..
