From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 0/4] l2tp: cleanup socket lookup code in l2tp_ip and
 l2tp_ip6
Date: Fri, 6 Jan 2017 20:03:53 +0100
Message-ID: <cover.1483727525.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:60895 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967878AbdAFTD5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 14:03:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First three patches remove redundant tests and add missing "const"
qualifiers.

Fourth patch splits the conditionals found in __l2tp_ip*_bind_lookup(),
to make these functions easier to review. In the process, I found that
some corner cases were still not handled properly. So I've added the
missing tests in this patch too, because they're pretty simple and the
whole "if" statements are modified anyway.

I expect it to be easier to review this way. If not, I can split up
patch #4, post the missing tests separately to -net, and later repost
this series as pure cleanup. Just let me know.


Guillaume Nault (4):
  l2tp: remove redundant addr_len check in l2tp_ip_bind()
  l2tp: make __l2tp_ip*_bind_lookup() parameters 'const'
  l2tp: remove useless NULL check in __l2tp_ip{,6}_bind_lookup()
  l2tp: rework socket comparison in __l2tp_ip*_bind_lookup()

 net/l2tp/l2tp_ip.c  | 29 ++++++++++++++++++-----------
 net/l2tp/l2tp_ip6.c | 30 +++++++++++++++++++-----------
 2 files changed, 37 insertions(+), 22 deletions(-)

-- 
2.11.0
