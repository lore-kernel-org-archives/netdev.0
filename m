From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net 0/2] net: ipmr, ip6mr: fix static leaks on netns destruction
Date: Fri, 20 Nov 2015 13:54:18 +0100
Message-ID: <1448024060-20466-1-git-send-email-razor@blackwall.org>
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35057 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760137AbbKTM4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 07:56:03 -0500
Received: by wmdw130 with SMTP id w130so18555608wmd.0
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 04:56:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
While testing various ipmr scenarios I found that static mfc entries and
static devices get leaked on netns/table destruction because
mroute_clean_tables doesn't delete them. It is fine to leave the static
entries when cleaning up the mrtsock, but when destroying the table they
need to be removed.

Cheers,
 Nik

Nikolay Aleksandrov (2):
  net: ipmr: fix static mfc/dev leaks on table destruction
  net: ip6mr: fix static mfc/dev leaks on table destruction

 net/ipv4/ipmr.c  | 15 ++++++++-------
 net/ipv6/ip6mr.c | 15 ++++++++-------
 2 files changed, 16 insertions(+), 14 deletions(-)

-- 
2.4.3
