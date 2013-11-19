From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next RFC v2 1/2] ipv6 addrconf: extend ifa_flags to
 u32
Date: Tue, 19 Nov 2013 16:16:53 -0500 (EST)
Message-ID: <20131119.161653.1620911822393300977.davem@davemloft.net>
References: <1384857809-6573-1-git-send-email-jiri@resnulli.us>
	<1384857809-6573-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334Ab3KSVQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 16:16:56 -0500
In-Reply-To: <1384857809-6573-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 19 Nov 2013 11:43:28 +0100

> There is no more space in u8 ifa_flags. So do what davem suffested and
> add another netlink attr called IFA_FLAGS for carry more flags.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Thomas Haller <thaller@redhat.com>
> ---
> v1->v2:
> - reordered struct inet6_ifaddr as suggested by David Laight
> - changed flags type to u32 on couple of places as suggested by Thomas Haller
> - changed output of if6_seq_show as suggested by Thomas Haller

This looks fine, but I would suggest to extend this to all addressing
types using ifm->ifa_flags.  It is not such a big deal, there are only
3 or 4.

DecNET, ipv4, ipv6, and lastly phonet (which just reports "permanent"
flag on get/dump).

That way tools like iproute2 can just generically provide and
interpret IFA_FLAGS attribute unconditionally.
