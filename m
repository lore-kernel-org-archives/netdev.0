From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net-next 13/15] smc: receive data from RMBE
Date: Tue, 09 Aug 2016 14:32:45 -0700 (PDT)
Message-ID: <20160809.143245.2022037008405834176.davem@davemloft.net>
References: <1470737580-43012-1-git-send-email-ubraun@linux.vnet.ibm.com>
	<1470737580-43012-14-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35086 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932404AbcHIVcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 17:32:48 -0400
Received: by mail-pf0-f196.google.com with SMTP id h186so1501742pfg.2
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 14:32:47 -0700 (PDT)
In-Reply-To: <1470737580-43012-14-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Tue,  9 Aug 2016 12:12:58 +0200

> +		xchg(&conn->rx_curs_confirmed.acurs,
> +		     smc_curs_read(conn->local_tx_ctrl.cons.acurs));

Why in the world do you need to use xchg() in all of these places?

It makes no sense whatsoever, especially since you don't even check
the return value.

If you need the operation to be atomic, then you have to check the
return value and do something to recover if something else beat
you to the xchg() and put something else into the location.

Otherwise, you therefore don't need it be atomic and can avoid
this expensive operation and just store the value normally.
