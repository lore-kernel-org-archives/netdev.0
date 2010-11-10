From: Vasiliy Kulikov <segooon@gmail.com>
Subject: Re: [PATCH 3/3] net: tipc: fix information leak to userland
Date: Wed, 10 Nov 2010 18:54:26 +0300
Message-ID: <20101110155426.GA6484@albatros>
References: <1288545032-16481-1-git-send-email-segooon@gmail.com>
 <20101109.092630.260076036.davem@davemloft.net>
 <20101109203317.GA24933@albatros>
 <4CDA88FE.8040801@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org, jon.maloy@ericsson.com,
	allan.stephens@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:42623 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756333Ab0KJPyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 10:54:35 -0500
Content-Disposition: inline
In-Reply-To: <4CDA88FE.8040801@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 10, 2010 at 12:58 +0100, walter harms wrote:
> NTL the core problem was that sizeof sa_data is 14 while dev->name is IFNAMESZ=15.

With this code it is NOT a bug because the output buffer is much bigger
than 14 (128 bytes).  I think it was just designed to overflow 14 bytes,
assign sa_data[14] = 0 and ignore it (lack of snprintf() those days?).

Anywhere else sa_data[14] = ... is a bug.

-- 
Vasiliy
