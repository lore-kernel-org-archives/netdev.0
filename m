From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Tue, 27 Jan 2009 16:07:50 -0800 (PST)
Message-ID: <20090127.160750.120120703.davem@davemloft.net>
References: <497EF9AC.70104@poczta.onet.pl>
	<adawscgwbkj.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aluno3@poczta.onet.pl, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34151
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751038AbZA1AHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 19:07:53 -0500
In-Reply-To: <adawscgwbkj.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 27 Jan 2009 15:53:16 -0800

> but actually I still don't see how it's safe for a net driver to
> call skb_linearize() from its transmit routine, since there's a
> chance that that will unconditionally enable BHs?

It's simply not allowed.

dev_queue_xmit() at a higher level can do __skb_linearize()
because it does so before doing the rcu_read_lock_bh().
