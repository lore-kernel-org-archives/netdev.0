From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_mpls: fix undefined reference to
 ip6_route_output
Date: Sun, 26 Jul 2015 17:20:41 -0700 (PDT)
Message-ID: <20150726.172041.1776472283136301057.davem@davemloft.net>
References: <55AFFF47.8040704@cumulusnetworks.com>
	<20150723.000949.1617391267827343249.davem@davemloft.net>
	<55B0EFAD.1010007@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755144AbbG0AUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 20:20:44 -0400
In-Reply-To: <55B0EFAD.1010007@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>
Date: Thu, 23 Jul 2015 06:44:13 -0700

> On 7/23/15, 12:09 AM, David Miller wrote:
>> From: roopa <roopa@cumulusnetworks.com>
>> Date: Wed, 22 Jul 2015 13:38:31 -0700
>>
>>> I cant think of a way to fix the current problem with my patch...
>> I guess it's not obvious that adding CONFIG_MPLS_IPV6 would solve
>> the problem perfectly.
> I thought that was not an option because CONFIG_MPLS_ROUTING is
> already out and supports IPV6 when RTA_OIF is
> specified.
> 
> I did submit another version yesterday using IS_BUILTIN (sorry missed
> the v2 in the patch prefix).
> https://patchwork.ozlabs.org/patch/498903/
> 
> I can certainly introduce CONFIG_MPLS_IPV6, if that is a more
> acceptable.

Also, IS_BUILTIN() is the wrong check, because this works properly also
when both MPLS_ROUTING and IPV6 are modular.

You need to encode this in the Kconfig dependencies of a new option
(which uses the dependency expression "IPV6 || IPV6=n"), then you can
key off of that Kconfig symbol to determine whether you need to
provide those NOP fallbacks or not.  There really is no other option.
