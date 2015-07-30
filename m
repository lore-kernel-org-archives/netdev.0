From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/2] af_mpls: fix undefined reference to
 ip6_route_output with CONFIG_IPV6=n
Date: Wed, 29 Jul 2015 22:42:23 -0700 (PDT)
Message-ID: <20150729.224223.1592092790674598920.davem@davemloft.net>
References: <1438122461-8350-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, hannes@stressinduktion.org, rshearma@brocade.com,
	stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	jon.maloy@ericsson.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36190 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbbG3Fm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 01:42:26 -0400
In-Reply-To: <1438122461-8350-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue, 28 Jul 2015 15:27:39 -0700

> v4 - v5: Use ipv6_stub_impl.ipv6_dst_lookup as suggested by Hannes

I think this might not work.

The ipv6_stub pointer is NULL until the ipv6 module is loaded.

VXLAN can safely call through ipv6_stub->foo() because it _knows_ the
ipv6 module has been loaded, and will not go away, because it is
working with an ipv6 socket.

You don't have that set of preconditions here, and thus it is pretty
easy to generate a scenerio where ipv6_stub will be NULL at your call
sites.

This is starting to get really messy, to be honest.  And we've been
harboring this build failure for several days now.
