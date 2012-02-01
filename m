From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Implement IP_UNICAST_IF socket option.
Date: Wed, 01 Feb 2012 14:12:32 -0500 (EST)
Message-ID: <20120201.141232.458020616314562146.davem@davemloft.net>
References: <1327622268-15602-1-git-send-email-ehoover@mines.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ehoover@mines.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753014Ab2BATMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 14:12:35 -0500
In-Reply-To: <1327622268-15602-1-git-send-email-ehoover@mines.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Erich E. Hoover" <ehoover@mines.edu>
Date: Thu, 26 Jan 2012 16:57:48 -0700

> The IP_UNICAST_IF feature is needed by the Wine project.  This patch
> implements the feature by setting the outgoing interface in the same
> fashion as that of IP_PKTINFO.
> 
> Signed-off-by: Erich E. Hoover <ehoover@mines.edu>

Hmmm, this is not how IP_UNICAST_IF is implemented in other systems.

The passed in argument is always a 32-bit network byte order word, and
it is always interpreted as an interface index only.  There are no
provisions for specifying an IPV4 address.

I see no value in exporting a different API than what other systems
use, especially if you are adding this interface exactly for providing
support for WINE applications, so please don't do this thing with
argument sizes and ip_mreqn.
