From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after	some time
Date: Mon, 8 Sep 2008 19:26:00 -0700
Message-ID: <OF2B044257.7CFC8C8A-ON882574BF.000BDAA8-882574BF.000D5E4E@us.ibm.com>
References: <20080909003852.GA20315@pest>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Bernhard Schmidt <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:51408 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbYIIC01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 22:26:27 -0400
In-Reply-To: <20080909003852.GA20315@pest>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Did you specify the interface on those?

I don't know whether or not I should trust that sin_scope_id==0,
which Brian also mentioned.

For link-local addresses, it must be specified, though you can
get there from an SO_BINDTODEVICE too. The error if it isn't
there is EINVAL, but sin_scope_id is showing as 0 for both cases.
The send side shouldn't actually care anything about the group
number unless they matched different routes, which I don't see
in your routing table.

So, I think it's back to running it on a debug kernel that prints
something distinguishing from the different EINVAL cases
to narrow it down.

                                        +-DLS

