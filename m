From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] include listenq max/backlog in tcp_info and related
 reports - correct version/signorder
Date: Mon, 17 Sep 2007 14:26:56 -0700 (PDT)
Message-ID: <20070917.142656.35665362.davem@davemloft.net>
References: <200709171950.MAA14825@tardy.cup.hp.com>
	<46EEDE35.8090102@psc.edu>
	<46EEE3D4.2070906@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52624
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753058AbXIQV1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 17:27:01 -0400
In-Reply-To: <46EEE3D4.2070906@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 17 Sep 2007 13:30:12 -0700

> Different fields for different structures.   The tcp_info struct doesn't 
> have the idiag_mumble, so to get the two values shown in /proc/net/tcp I 
> use tcpi_unacked and tcpi_sacked.
> 
> For the INET_DIAG_INFO stuff the idiag_mumble fields are used and that 
> then covers ss.

I want to reiterate what has been stated earlier in reply to this
patch in that we shouldn't be modifying /proc/net/tcp* at all,
any change can break some application parsing the strings it
spits out.

Therefore only the inet_diag thing can have the fields added
in a backward compatible manner.

Actually, this is why I initially deleted this patch from my inbox
without applying it, I didn't see you remove the procfs code
based upon the feedback you got stating that was necessary.
