From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Mon, 26 Oct 2009 18:24:29 -0700 (PDT)
Message-ID: <20091026.182429.55413765.davem@davemloft.net>
References: <OF703F980D.0971407E-ON6525765B.00458CCA-6525765B.00481976@in.ibm.com>
	<200910261631.44666.opurdila@ixiacom.com>
	<4AE5B84E.8040505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, krkumar2@in.ibm.com, hagen@jauu.net,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60675
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755480AbZJ0BYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 21:24:05 -0400
In-Reply-To: <4AE5B84E.8040505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 26 Oct 2009 15:55:10 +0100

> But should we really care ?

The only thing I see consistently in this thread is that
jhash performs consistently well and without any tweaking.

And without any assumptions about the characteristics of
the device names.  I've seen everything from the traditional
"eth%d" to things like "davem_is_a_prick%d" so you really cannot
optimize for anything in particular.

Jenkins is ~50 cycles per round of 4 bytes last time I checked, give
or take, and that was on crappy sparc. :-) So the execution cost is
really not that bad, contrary to what I've seen claimed as an argument
against using jhash here.

And if I-cache footprint is really an issue, we can have one
out-of-line expansion of jhash somewhere under lib/ since we use jhash
in so many places these days.
