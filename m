From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] vlan: lockless transmit path
Date: Thu, 11 Nov 2010 18:52:58 +0100
Message-ID: <1289497978.17691.1582.camel@edumazet-laptop>
References: <1289468520.17691.1018.camel@edumazet-laptop>
	 <AANLkTikBkUNfrfSZkoVd1xzisD3jgg5kVUUZC45gNpde@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41732 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242Ab0KKRxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 12:53:01 -0500
Received: by eye27 with SMTP id 27so1308344eye.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 09:53:00 -0800 (PST)
In-Reply-To: <AANLkTikBkUNfrfSZkoVd1xzisD3jgg5kVUUZC45gNpde@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 11 novembre 2010 =C3=A0 09:40 -0800, Jesse Gross a =C3=A9crit =
:

> If we're only allocating a single queue then we should also drop
> vlan_dev_select_queue() and the netdev_ops that call it.  If the
> underlying device is multiqueue and has its own select_queue function
> then it can pick a queue number that is larger than what the vlan
> device has.  The problem will be caught by dev_cap_txqueue() but it's
> not right and it would also be nice to get rid of half of those
> netdev_ops.

Hmm, you refer to old kernels dont you ?

My patch is for net-next

The plan is that after last Tom Herbert patches, dev_pick_tx()  wont
call do_select_queue() on mono queue device.

http://patchwork.ozlabs.org/patch/70369/


This logicaly is a second cleanup patch I believe.


