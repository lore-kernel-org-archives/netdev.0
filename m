From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Mon, 07 Jul 2008 15:45:38 -0700
Message-ID: <adafxqlxqi5.fsf@cisco.com>
References: <20080706130801.6bc36cf7@infradead.org>
	<20080706.155318.46569612.davem@davemloft.net>
	<20080706180842.36cc0b1c@extreme>
	<20080706.182243.65603166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, arjan@infradead.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:14207 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081AbYGGWpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 18:45:40 -0400
In-Reply-To: <20080706.182243.65603166.davem@davemloft.net> (David Miller's
	message of "Sun, 06 Jul 2008 18:22:43 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > > For consistency each call through ethtool_ops should
 > > be holding rtnl mutex. And since dev_watchdog is a timer routine,
 > > it is not safe to acquire a mutex there.
 > 
 > I think "get driver info", which does nothing but copy strings out of
 > the driver software state, is a safe exception to these strict locking
 > rules.

it seems that's not universally the case, eg get_drvinfo() in
drivers/net/cxgb3/cxgb3_main.c does

	t3_get_fw_version(adapter, &fw_vers);
	t3_get_tp_version(adapter, &tp_vers);

and from reading further in the code it's not obvious that this is safe
to do without serialization (it calls into t3_read_flash(), which does a
typical "write address reg, read data reg" sequence to access flash,
without any locking).

 - R.
