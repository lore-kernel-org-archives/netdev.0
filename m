From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] sctp: fix the transport dead race check by
 using atomic_add_unless on refcnt
Date: Mon, 25 Jan 2016 10:44:46 -0800 (PST)
Message-ID: <20160125.104446.2231255639148070984.davem@davemloft.net>
References: <56A25DCC.9040207@gmail.com>
	<20160122171812.GI3452@mrl.redhat.com>
	<56A27AD1.9040502@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcelo.leitner@gmail.com, lucien.xin@gmail.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	daniel@iogearbox.net
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755589AbcAYSou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 13:44:50 -0500
In-Reply-To: <56A27AD1.9040502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Fri, 22 Jan 2016 13:54:09 -0500

> OK,  I see how that holds together, but I think there might be hole wrt icmp
> handling.  Some icmp processes assume transport can't disappear on them, but in
> this case that last put(transport) may result in a call to sctp_transport_destroy()
> and that might be bad.  I am looking at it now.

Vlad, this patch series is being held up because of this.  Please resolve
this one way or the other at your earliest possible convenience, thanks.
