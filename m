From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 1/3] ipv4: make flow functions more grepable by
 removing flowi4_init_output
Date: Wed, 15 Jun 2016 12:48:00 -0700 (PDT)
Message-ID: <20160615.124800.889153492414820174.davem@davemloft.net>
References: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org>
	<1465850858-8559-2-git-send-email-hannes@stressinduktion.org>
	<6b8ad88f-db0b-3a88-197d-ed7278783bfc@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org, ja@ssi.bg
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867AbcFOTsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 15:48:01 -0400
In-Reply-To: <6b8ad88f-db0b-3a88-197d-ed7278783bfc@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 13 Jun 2016 16:02:53 -0600

> I found this helper to be unhelpful developing the VRF changes. Really
> obfuscates the initialization of the flow struct. Happy to see it go.

The whole point was so that it would actually be easier.

If flow structures only get initialized by 2 or 3 helpers, then when
adding new flow fields you only need to update the helpers.

Since you have to update the helper argument signatures in order to do
this, you would be forced to update all call sites and make sure they
passed in suitable new argument(s).

But if people don't use the helpers, and initialize flow structures
on their own, yeah that defeats the whole mechanism and things will
seem harder and "unhelpful".

I really think this is a step backwards.
