From: Timo Teras <timo.teras@iki.fi>
Subject: netlink NLM_F_DUMP for unsupported address family / PF_UNSPEC
Date: Thu, 27 Dec 2012 17:19:17 +0200
Message-ID: <20121227171917.07419887@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:59668 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752932Ab2L0PTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2012 10:19:33 -0500
Received: by mail-ee0-f43.google.com with SMTP id e49so4865870eek.2
        for <netdev@vger.kernel.org>; Thu, 27 Dec 2012 07:19:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that currently PF_UNSPEC is overloaded when dumping rtnetlink
things. It is used for two purposes: as wildcard entry to dump
all protocol families, and as fallback for unsupported families.

On my system with IPv[46] only and no IPX, running "ip -f ipx
route" would print the IPv4 and IPv6 routes instead of "unsupported" or
"not implemented" error which is rather confusing and unexpected.

Just removing the fallback from rtnl_get_dumpit() does not sound right
since some commands seem to rely on this behaviour e.g. RTM_GETQDISC.

Perhaps rtnl_dump_all should check that request family truly was
PF_UNSPEC or error out if not?

- Timo
