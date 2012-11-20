From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: team: add broadcast mode
Date: Tue, 20 Nov 2012 22:23:07 +0300
Message-ID: <20121120192307.GA10278@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29600 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470Ab2KTTXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 14:23:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jiri Pirko,

The patch 5fc889911a99: "team: add broadcast mode" from Jul 11, 2012, 
leads to the following Smatch warning:
drivers/net/team/team_mode_broadcast.c:46 bc_transmit()
	 warn: signedness bug returning '18446744073709551516'

The error message sucks because 18446744073709551516 is -100 as an int,
and I'm not sure how it figures this returns -100...

But actually there is a signedness bug in bc_transmit().  We return
error codes from team_dev_queue_xmit() and cast them to 1 as bool.  This
function is supposed to return 1 on success but instead it returns zero.

regards,
dan carpenter
