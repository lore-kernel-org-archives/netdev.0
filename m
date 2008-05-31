From: Brice Goglin <brice@myri.com>
Subject: howto use ioremap_wc?
Date: Sat, 31 May 2008 11:02:54 +0200
Message-ID: <4841143E.5080003@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"venkatesh.pallipadi@intel.com" <venkatesh.pallipadi@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2028 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750710AbYEaJDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 May 2008 05:03:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We're looking at using ioremap_wc() in myri10ge. No drivers seem to be
using it yet, so I'd like to get some clarification regarding ioremap_wc
failures, MTRR and so on.

What we currently do is mtrr_add() and then ioremap. Depending on the
mtrr_add() success, we use the "wc_fifo" or regular PIO with fences to
submit requests to the NIC. How are we supposed to switch this to
ioremap_wc?

Are we sure that if the arch supports _wc, it does not return success
when the underlying plain ioremap worked but setting up _wc() failed? If
so, why does it revert to ioremap_nocache when PAT isn't enabled?

Can we keep the mtrr_add() in the regular path? Or are we supposed to
drop it when the arch provides ioremap_wc and it did not fail?

thanks,
Brice

