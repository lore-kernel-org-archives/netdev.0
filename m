From: David Miller <davem@davemloft.net>
Subject: mpls's find_outdev()
Date: Thu, 07 Apr 2016 21:41:09 -0400 (EDT)
Message-ID: <20160407.214109.32624032556886158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57610 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756283AbcDHBlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 21:41:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While auditing something unrelated, I noticed that this function seems
to potentially dev_put() on an error pointer.

I guess the problem comes from the fact that there are two methods
by which the device pointer is obtained.

First, inet{,6}_fib_lookup_dev() which uses error pointers.

Second, dev_get_by_index() which returns a valid device or NULL,
and therefore does not use error pointers.

If inet{,6}_fib_lookup_dev() returns an error pointer, the !dev check
will not pass and dev_put() will operate on an error pointer and
crash.

If you agree with my analysis, could you please cook up and test a
fix?

Thank you!
