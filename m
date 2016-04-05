From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: remove unimplemented RTNH_F_PERVASIVE
Date: Tue, 05 Apr 2016 19:57:59 -0400 (EDT)
Message-ID: <20160405.195759.110758435613250333.davem@davemloft.net>
References: <56FFED8B.7010701@cogentembedded.com>
	<1459615888-456-1-git-send-email-quentin@armitage.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: quentin@armitage.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760532AbcDEX6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 19:58:01 -0400
In-Reply-To: <1459615888-456-1-git-send-email-quentin@armitage.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Armitage <quentin@armitage.org.uk>
Date: Sat,  2 Apr 2016 17:51:28 +0100

> Linux 2.1.68 introduced RTNH_F_PERVASIVE, but it had no implementation
> and couldn't be enabled since the required config parameter wasn't in
> any Kconfig file (see commit d088dde7b196 ("ipv4: obsolete config in
> kernel source (IP_ROUTE_PERVASIVE)")).
> 
> This commit removes all remaining references to RTNH_F_PERVASIVE.
> Although this will cause userspace applications that were using the
> flag to fail to build, they will be alerted to the fact that using
> RTNH_F_PERVASIVE was not achieving anything.
> 
> Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>

Can't really delete values like this from user visible headers.  It
can break the build.

What if some library or tool has a table translating RTNH_F_* values
into strings to display to the user?  Those sources will stop building
if I apply your changes.
