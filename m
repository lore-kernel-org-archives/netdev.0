From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.30-rc1: e1000: list_add corruption
Date: Wed, 08 Apr 2009 21:20:40 -0700 (PDT)
Message-ID: <20090408.212040.184687004.davem@davemloft.net>
References: <a4423d670904082045q41274747ha08d28a0645ae378@mail.gmail.com>
	<a4423d670904082048i26585b9boacf7ae449e004b8c@mail.gmail.com>
	<a4423d670904082116q452d369ds3e3a498baef5f70b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-testers@vger.kernel.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: a.beregalov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49056
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752066AbZDIEUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 00:20:49 -0400
In-Reply-To: <a4423d670904082116q452d369ds3e3a498baef5f70b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Thu, 9 Apr 2009 08:16:00 +0400

> The host has two interfaces
> eth0 - e1000, eth1 - forcedeth.
> Both are not working after that messages.

It looks like the NAPI pending list is being modified in an illegal
state by forcedeth, and mid-stream to a list_del() an e1000 interrupt
comes in and this tries to schedule the e1000 NAPI context and we get
list corruption.
