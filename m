From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Nagle latency tuning
Date: Mon, 22 Sep 2008 04:09:12 -0700 (PDT)
Message-ID: <20080922.040912.193700258.davem@davemloft.net>
References: <48C6C300.4050102@redhat.com>
	<20080909.125934.150042096.davem@davemloft.net>
	<20080922.034933.119934091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, rick.jones2@hp.com, netdev@vger.kernel.org
To: csnook@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44225
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752061AbYIVLJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 07:09:24 -0400
In-Reply-To: <20080922.034933.119934091.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 22 Sep 2008 03:49:33 -0700 (PDT)

> I'll try to figure out why Andi's patch doesn't behave as expected.

Andi's patch uses proc_dointvec_jiffies, which is for sysctl values
stored as seconds, whereas these things are used to record values with
smaller granulatiry, are stored in jiffies, and that's why we get zero
on read and writes have crazy effects.

Also, as Andi stated, this is not the way to deal with this problem.

So we have a broken patch, which even if implemented properly isn't the
way forward, so I consider this discussion dead in the water until we
have some test cases.

Don't you think? :-)
