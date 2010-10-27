From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] tipc: Fix bugs in tipc_msg_calc_data_size()
Date: Wed, 27 Oct 2010 12:17:05 -0700 (PDT)
Message-ID: <20101027.121705.116393146.davem@davemloft.net>
References: <1288206816-23025-1-git-send-email-paul.gortmaker@windriver.com>
	<1288206816-23025-2-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	drosenberg@vsecurity.com, jon.maloy@ericsson.com,
	security@kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57123
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755440Ab0J0TQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 15:16:41 -0400
In-Reply-To: <1288206816-23025-2-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Wed, 27 Oct 2010 15:13:33 -0400

> From: Allan Stephens <Allan.Stephens@windriver.com>
> 
> Enhances TIPC's computation of the amount of data to be sent so that
> it works properly when large values are involved. Calculations are now
> done using "size_t" instead of "int", and a check has been added to
> handle cases where the total amount of data exceeds the range of "size_t".
> 
> Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>

The protocol socket I/O call ops can't even return anything larger
than an 'int' because of the signature for those function pointers
(check out *sendmsg and *recvmsg in include/linux/net.h).

So returning "long" from here doesn't make any sense.

You really have to limit the usable lengths to the range of
an 'int' all the way up to the code in net/socket.c

