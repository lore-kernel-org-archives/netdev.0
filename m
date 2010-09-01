From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Wed, 1 Sep 2010 08:41:14 -0700
Message-ID: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com>
References: <alpine.DEB.1.00.1008222233530.31382@pokey.mtv.corp.google.com>
	<20100823105933.27cd0b80@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:28649 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753581Ab0IAPlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 11:41:17 -0400
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id o81FfGip015826
	for <netdev@vger.kernel.org>; Wed, 1 Sep 2010 08:41:16 -0700
Received: from ywl5 (ywl5.prod.google.com [10.192.12.5])
	by hpaq5.eem.corp.google.com with ESMTP id o81FexcU010944
	for <netdev@vger.kernel.org>; Wed, 1 Sep 2010 08:41:15 -0700
Received: by ywl5 with SMTP id 5so2425942ywl.28
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 08:41:14 -0700 (PDT)
In-Reply-To: <20100823105933.27cd0b80@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Why don't we do this in the normal transmit processing.
> There is already so much policy mechanism filters/actions/qdisc that
> doing it in higher level is fighting against these.
>
Are you proposing that TX queue selection be done in the qdiscs?  The
queue has to be selected before taking the lock (cannot afford taking
a lock over the whole interface).  This would necessitate moving the
locking and probably rearranging a lot of the xmit code around that.

Tom
