From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general][PATCH 2/2] mlx4: ConnectX multi functional device support
Date: Wed, 24 Jun 2009 23:18:55 -0700
Message-ID: <adaws70lttc.fsf@cisco.com>
References: <4A3A34F5.9030800@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:62874 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbZFYGSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 02:18:53 -0400
In-Reply-To: <4A3A34F5.9030800@mellanox.co.il> (Yevgeny Petrilin's message of
	"Thu, 18 Jun 2009 15:37:09 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > MT26468 (0x6764) device can open multiple physical functions.
 > The current driver can only work with one (primary) pf.
 > For all other functions, QUERY_FW command would fail with
 > CMD_STAT_MULTI_FUNC_REQ error code. We should not work on those
 > devices, but they should remain in the driver's ownership.

Seems this patch should really be 1/2, since we want the driver to be
able to handle multi-func devices before we add the PCI ID for such
devices.  Also, it didn't occur to me before, but why does the driver
need to keep ownership of the non-primary functions?  It seems we could
avoid having the NOT_PRIME flag and all of that if we just gave up on a
device when QUERY_FW told us it wasn't the primary function.

Also from my naive point of view at least, it seems your hardware
interface could be simpler for software to handle if you just used a
different PCI ID for the non-primary physical function.  Not sure if
it's too late to change that (and maybe there's a reason I'm missing to
use the same PCI ID for functions that behave differently and require
different driver behavior to handle them??).

 - R.
