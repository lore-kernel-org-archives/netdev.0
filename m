From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: don't free static mem in the case of
 init_net
Date: Mon, 25 Mar 2013 13:16:12 -0400 (EDT)
Message-ID: <20130325.131612.839103976133079709.davem@davemloft.net>
References: <1364228725-16218-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: honkiko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757859Ab3CYRQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 13:16:14 -0400
In-Reply-To: <1364228725-16218-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <honkiko@gmail.com>
Date: Tue, 26 Mar 2013 00:25:25 +0800

> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>

1) This should be submitted against 'net' since it's clearly
   a real bug.

2) This needs to be fixed differently.  We should always
   kmemdup() and create fresh copies of these objects, even
   for init_net.  So 'dflt' and 'all' will start as "NULL"
   and always we will try to kmemdup(&ipv6_defconf, ...) and
   kmemdup(&ipv6_devconf_dflt, ...);
