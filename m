From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: Clear any capability flags that driver is
 not interested in.
Date: Tue, 13 Aug 2013 15:22:07 -0700 (PDT)
Message-ID: <20130813.152207.440378568111389533.davem@davemloft.net>
References: <208f9dff-8e74-4a44-bd94-6c79342e6a73@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwar.bandi@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44845 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757990Ab3HMWWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 18:22:08 -0400
In-Reply-To: <208f9dff-8e74-4a44-bd94-6c79342e6a73@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <sarveshwar.bandi@emulex.com>
Date: Mon, 12 Aug 2013 11:21:09 +0530

> From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> 
> It is possible for some versions of firmware to advertise capabilities that driver
> is not ready to handle. This may lead to controller stall. Clear all flags that driver
> is not interested in.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

This is so ugly and hard to understand.

The issue is that the capabilities come from an external entity, in
be_cmd_get_func_config().

So that's the place where you should clear the bits that the drive
doesn't understand.

Also, put the new macro into a sane place like a header file close
to the existing individual BE_IF_FLAGS_* defines.  And name it sanely,
something like "BE_IF_FLAGS_ALL".
