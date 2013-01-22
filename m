From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Tue, 22 Jan 2013 14:44:13 -0800
Message-ID: <1358894653.12374.201.camel@edumazet-glaptop>
References: <1358889648-1684-1-git-send-email-pshelar@nicira.com>
	 <1358892199.12374.139.camel@edumazet-glaptop>
	 <20130122.170826.1481012610894653735.davem@davemloft.net>
	 <1358892924.12374.157.camel@edumazet-glaptop>
	 <CAEP_g=_AebncQ6_tHDA0rN=ya4tAqpN2i8FuQ1hqa8mOgj_AJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, pshelar@nicira.com,
	netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:56218 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367Ab3AVWoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 17:44:16 -0500
Received: by mail-da0-f48.google.com with SMTP id k18so3455011dae.35
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 14:44:15 -0800 (PST)
In-Reply-To: <CAEP_g=_AebncQ6_tHDA0rN=ya4tAqpN2i8FuQ1hqa8mOgj_AJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-22 at 14:38 -0800, Jesse Gross wrote:

> 
> We're currently enforcing this assumption in the rest of the network
> stack - it's why we mask out scatter/gather capability in the NIC if
> it isn't capable of checksumming the packet.
> 
> Packets with asynchronous changes may come from VMs, so it isn't
> necessarily reasonable to tell people that they need to disable
> offloads with certain use cases.
> 
> As Pravin said, pushing down the GSO to the lowest layer is the best
> way to solve the problem.  However, I would argue that the current
> behavior is not correct.

You do understand this problem is generic to GSO ?

You basically are saying GSO should be removed.

If you really care, please find another way to address the problem.

Frames build by tcp_sendmsg() are fine : their content cannot be changed
by the user.
