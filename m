From: David Miller <davem@davemloft.net>
Subject: CAIF transmit bug
Date: Thu, 19 May 2011 17:44:15 -0400 (EDT)
Message-ID: <20110519.174415.182212433770446975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56728 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933194Ab1ESVoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 17:44:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net/caif/cfctrl.c:cfctrl_enum_req() does not check the return value of
the ->transmit() method.

The documentation for this method states that one error, ownership
of the packet is transferred back to the caller, which means that we
have a leak here.

Please fix this bug.
