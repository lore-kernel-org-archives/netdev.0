From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] netlink: use a statically allocated nl_table
 instead
Date: Sun, 16 Sep 2007 16:38:14 -0700 (PDT)
Message-ID: <20070916.163814.77649402.davem@davemloft.net>
References: <1188675959178-git-send-email-crquan@gmail.com>
	<11886759682348-git-send-email-crquan@gmail.com>
	<11886759772663-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cr_quan@163.com
To: crquan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38138
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754068AbXIPXiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:38:15 -0400
In-Reply-To: <11886759772663-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Cheng <crquan@gmail.com>
Date: Sun,  2 Sep 2007 03:45:59 +0800

> if the table is always fixed size with MAX_LINKS entries, why not use a statically
> allocated table straightforwardly?
> 
> Signed-off-by: Denis Cheng <crquan@gmail.com>

I made the explicit decision to dynamically allocate because
many systems have limits on how large the kernel image can
be and therefore the less we statically allocate huge tables
(constant size or not) the better.

Lockdep is the worst offender, for example, it's completely awful.  It
consumes 4MB of kernel BSS space when enabled on a 64-bit platform.

Patch not applied.
