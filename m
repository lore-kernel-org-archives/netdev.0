From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH V2] cdc_ncm: Add support for moving NDP to end of NCM
 frame
Date: Tue, 7 Jul 2015 22:50:41 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1507072243460.9655@localhost.localdomain>
References: <1435787748-30393-1-git-send-email-mrkiko.rs@gmail.com> <alpine.LNX.2.20.1507051219280.12595@archiso.lan> <1436177296.8225.25.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33144 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932713AbbGGUus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 16:50:48 -0400
In-Reply-To: <1436177296.8225.25.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver, hello to who is reading this message.

i was re-reading the code and the oops, without understanding what's the 
problem. Still: what impressed me is the fact that at some point you see NULL 
ptr dereference in unrelated code (fbcon). Is it possible that at some point 
the memory portion (172 bytes if device is affected by NCM errata, and mine 
is), that the portion of memory to which ctx->delayed_ndp16 points to is 
somehow moved / thrown away?
It doesn't make sense, because otherwise even accesses to the ctx variable 
would give problems. And they don't.
Looking around then, I see kzalloc() / kmalloc (kzalloc =kmalloc | __GFP_ZERO) 
are used to allocate any size of memory (with the only requirement for it to be 
small). In rndis_host.c 1025 bytes (not 1024) are allocated, so I am excluding 
any kind of alignment problem here.

Thank you,
Enrico
