From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: avoid atomic allocations during initialization
Date: Sat, 07 Sep 2013 00:29:52 -0400 (EDT)
Message-ID: <20130907.002952.1951928882694928547.davem@davemloft.net>
References: <1378411989-19775-1-git-send-email-mschmidt@redhat.com>
	<20130906.142735.458916282873797040.davem@davemloft.net>
	<504C9EFCA2D0054393414C9CB605C37F20D90E3D@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org, ariele@broadcom.com,
	eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53329 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787Ab3IGE34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 00:29:56 -0400
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F20D90E3D@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Sat, 7 Sep 2013 01:45:10 +0000

> Once you allocated the memory during initialization , you will most
> probably fail to allocate its replacement during RX handling (on
> this machine).

Not true, these two events can exist in totally different timeframes
and totally different memory pressure situations.

Probe should never fail because of an atomic memory allocation if at
all possible.

You should use sleeping allocations in every possible situation for
maximum stability, and this absolutely matches the approach taken
by every other major driver.
